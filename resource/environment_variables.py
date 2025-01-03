VERSION = input("請輸入版本資訊 (例如: 1.0.0): ").strip()
if not VERSION:
    raise ValueError("版本資訊不能為空")

ENV = input("請輸入環境 (例如: TEST 或 STAGE): ").strip().upper()
browser = "chromium"

if ENV == "TEST":
    url = "http://192.168.11.191/web/NewEnergyStorage/ihouseEMS/login.html"
    org = "Orange"
    acc = "CwoAdmin"
    pw = "P@ssw0rd"
    widget_threedots = ".icon.icon-three-dots.icon-40"
    opt1 = "1f07e4c4-a849-4c72-8a55-24eaeabca923"
    opt2 = "b516d54e-bd37-4710-a11f-ffebc06ed677"
    node_id = "VTP-0001"
elif ENV == "STAGE":
    url = "https://stage.ihouseems.com/web/NewEnergyStorage/ihouseEMS/login.html"
    org = "TestCwo"
    acc = "TestAdmin"
    pw = "P@ssw0rd"
    widget_threedots = ".icon.icon-three-dots.icon-40.float-end"
    opt1 = "179bafaf-e5c2-42e4-b9b3-e0e3fb5fa636"
    opt2 = "2bfd8f82-8c10-452b-90ab-b6d894311d91"
    node_id = "VTP-0001"
elif ENV == "ACER":
    url = "http://192.168.11.123/ihouseBA/login.html"
    acc = "admin"
    pw = "P@ssw0rd"
    init_label = "13-1"
    device1 = "0CFE5DEF6376"    #widget設定用
    device2 = "_devGroup1-VTE-0047"
elif ENV == "LA":
    url = "http://192.168.11.88/ihouseBA/"
    acc = "admin"
    pw = "P@ssw0rd"
    uid = "61de9c98-a9b6-4756-9de8-0b4907ae5ef7"
    device1 = "0CFE5DEF6376"
    device2 = "0CFE5DEF6376-1"
else:
    raise ValueError("Invalid environment specified. Use TEST or STAGE.")