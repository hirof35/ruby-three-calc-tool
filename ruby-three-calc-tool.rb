require 'tk'
require 'tkextlib/tile' # 綺麗な見た目（ttk）を使うために必要

root = TkRoot.new { title "業務支援ツール (見積・納品・給与)" }
root.geometry("600x500")

# タブコントロールの作成
notebook = Tk::Tile::Notebook.new(root) { pack('fill' => 'both', 'expand' => true) }

# ----------------------------------------------------------------------
# 1. 見積書作成タブ
# ----------------------------------------------------------------------
tab_estimate = Tk::Tile::Frame.new(notebook)
notebook.add(tab_estimate, 'text' => '見積書作成')

# 入力項目の配置
Tk::Tile::Label.new(tab_estimate, 'text' => '宛名:').grid('row' => 0, 'column' => 0, 'padx' => 10, 'pady' => 10, 'sticky' => 'w')
est_client = Tk::Tile::Entry.new(tab_estimate).grid('row' => 0, 'column' => 1, 'padx' => 10, 'pady' => 10)

Tk::Tile::Label.new(tab_estimate, 'text' => '品目:').grid('row' => 1, 'column' => 0, 'padx' => 10, 'pady' => 10, 'sticky' => 'w')
est_item = Tk::Tile::Entry.new(tab_estimate).grid('row' => 1, 'column' => 1, 'padx' => 10, 'pady' => 10)

Tk::Tile::Label.new(tab_estimate, 'text' => '金額 (円):').grid('row' => 2, 'column' => 0, 'padx' => 10, 'pady' => 10, 'sticky' => 'w')
est_price = Tk::Tile::Entry.new(tab_estimate).grid('row' => 2, 'column' => 1, 'padx' => 10, 'pady' => 10)

# 出力エリア
est_output = TkText.new(tab_estimate, 'width' => 60, 'height' => 12).grid('row' => 4, 'column' => 0, 'columnspan' => 2, 'padx' => 10, 'pady' => 10)

# 発行ボタンの処理
est_btn = Tk::Tile::Button.new(tab_estimate, 'text' => '見積書を発行') {
  command proc {
    client = est_client.value
    item = est_item.value
    price = est_price.value.to_i
    tax = (price * 0.1).to_i
    total = price + tax

    text = "【御見積書】\n"
    text += "御中: #{client} 様\n"
    text += "----------------------------------------\n"
    text += "品目: #{item}\n"
    text += "小計: ￥#{price.to_s.gsub(/(\d)(?=\d{3}+$)/, '\\1,')}\n"
    text += "消費税(10%): ￥#{tax.to_s.gsub(/(\d)(?=\d{3}+$)/, '\\1,')}\n"
    text += "合計金額: ￥#{total.to_s.gsub(/(\d)(?=\d{3}+$)/, '\\1,')}\n"
    text += "----------------------------------------\n"
    text += "有効期限: 発行日から1ヶ月\n"
    
    est_output.value = text
  }
}.grid('row' => 3, 'column' => 0, 'columnspan' => 2, 'pady' => 10)


# ----------------------------------------------------------------------
# 2. 納品書作成タブ
# ----------------------------------------------------------------------
tab_delivery = Tk::Tile::Frame.new(notebook)
notebook.add(tab_delivery, 'text' => '納品書作成')

Tk::Tile::Label.new(tab_delivery, 'text' => '納品先:').grid('row' => 0, 'column' => 0, 'padx' => 10, 'pady' => 10, 'sticky' => 'w')
del_client = Tk::Tile::Entry.new(tab_delivery).grid('row' => 0, 'column' => 1, 'padx' => 10, 'pady' => 10)

Tk::Tile::Label.new(tab_delivery, 'text' => '納品内容:').grid('row' => 1, 'column' => 0, 'padx' => 10, 'pady' => 10, 'sticky' => 'w')
del_item = Tk::Tile::Entry.new(tab_delivery).grid('row' => 1, 'column' => 1, 'padx' => 10, 'pady' => 10)

del_output = TkText.new(tab_delivery, 'width' => 60, 'height' => 12).grid('row' => 3, 'column' => 0, 'columnspan' => 2, 'padx' => 10, 'pady' => 10)

del_btn = Tk::Tile::Button.new(tab_delivery, 'text' => '納品書を発行') {
  command proc {
    text = "【納品書】\n"
    text += "御中: #{del_client.value} 様\n"
    text += "----------------------------------------\n"
    text += "下記の通り納品いたしました。\n\n"
    text += "内容: #{del_item.value}\n"
    text += "----------------------------------------\n"
    text += "ご確認のほど、よろしくお願い申し上げます。\n"
    del_output.value = text
  }
}.grid('row' => 2, 'column' => 0, 'columnspan' => 2, 'pady' => 10)


# ----------------------------------------------------------------------
# 3. 給与計算ツールタブ
# ----------------------------------------------------------------------
tab_salary = Tk::Tile::Frame.new(notebook)
notebook.add(tab_salary, 'text' => '給与計算ツール')

Tk::Tile::Label.new(tab_salary, 'text' => '時給 (円):').grid('row' => 0, 'column' => 0, 'padx' => 10, 'pady' => 10, 'sticky' => 'w')
sal_hourly = Tk::Tile::Entry.new(tab_salary).grid('row' => 0, 'column' => 1, 'padx' => 10, 'pady' => 10)

Tk::Tile::Label.new(tab_salary, 'text' => '労働時間 (時間):').grid('row' => 1, 'column' => 0, 'padx' => 10, 'pady' => 10, 'sticky' => 'w')
sal_hours = Tk::Tile::Entry.new(tab_salary).grid('row' => 1, 'column' => 1, 'padx' => 10, 'pady' => 10)

sal_output = TkText.new(tab_salary, 'width' => 60, 'height' => 12).grid('row' => 3, 'column' => 0, 'columnspan' => 2, 'padx' => 10, 'pady' => 10)

sal_btn = Tk::Tile::Button.new(tab_salary, 'text' => '給与計算') {
  command proc {
    hourly = sal_hourly.value.to_i
    hours = sal_hours.value.to_f
    
    # 簡易計算（基本給、所得税概算、雇用保険概算など）
    base_pay = (hourly * hours).to_i
    tax = (base_pay * 0.05).to_i       # 所得税一律5%と仮定
    insurance = (base_pay * 0.006).to_i # 雇用保険一律0.6%と仮定
    net_pay = base_pay - tax - insurance

    text = "【給与明細概算】\n"
    text += "----------------------------------------\n"
    text += "基本給 (時給 #{hourly}円 × #{hours}時間): ￥#{base_pay.to_s.gsub(/(\d)(?=\d{3}+$)/, '\\1,')}\n"
    text += "----------------------------------------\n"
    text += "【控除額】\n"
    text += "  所得税(概算5%): ￥#{tax.to_s.gsub(/(\d)(?=\d{3}+$)/, '\\1,')}\n"
    text += "  雇用保険(概算0.6%): ￥#{insurance.to_s.gsub(/(\d)(?=\d{3}+$)/, '\\1,')}\n"
    text += "----------------------------------------\n"
    text += "差引支給額（手取り）: ￥#{net_pay.to_s.gsub(/(\d)(?=\d{3}+$)/, '\\1,')}\n"
    text += "----------------------------------------\n"
    
    sal_output.value = text
  }
}.grid('row' => 2, 'column' => 0, 'columnspan' => 2, 'pady' => 10)

# アプリケーションの実行
Tk.mainloop
