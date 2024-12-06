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
    device1 = "4ae41bf1-e9df-440f-a0aa-17bca767b7d5"
    device2 = "1179b2d4-cfce-4795-9a43-62222a2ad1c0"
    node_id = "VTP-0001"
elif ENV == "STAGE":
    url = "https://stage.ihouseems.com/web/NewEnergyStorage/ihouseEMS/login.html"
    org = "TestCwo"
    acc = "TestAdmin"
    pw = "P@ssw0rd"
    widget_threedots = ".icon.icon-three-dots.icon-40.float-end"
    device1 = "179bafaf-e5c2-42e4-b9b3-e0e3fb5fa636"
    device2 = "2bfd8f82-8c10-452b-90ab-b6d894311d91"
    node_id = "VTP-0001"
elif ENV == "ACER":
    url = "http://192.168.11.123/ihouseBA/login.html"
    acc = "admin"
    pw = "P@ssw0rd"
    init_label = "13-1"
    device1 = "TYTTEEST"
    device2 = "_devGroup1-VTE-0047"
elif ENV == "LA":
    url = "http://192.168.11.88/ihouseBA/"
    acc = "admin"
    pw = "P@ssw0rd"
    uid = "61de9c98-a9b6-4756-9de8-0b4907ae5ef7"
    init_label = "13-1"
    device1 = "0CFE5DEF6376"
    device2 = "0CFE5DEF6376-1"
else:
    raise ValueError("Invalid environment specified. Use TEST or STAGE.")