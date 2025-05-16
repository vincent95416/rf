browser = "chromium"
# 環境列表與預設
ENVIRONMENTS = {
    "EMS":{
        "variables":{
            "url": "http://192.168.11.191/web/NewEnergyStorage/ihouseEMS/login.html",
            "org": "Orange",
            "acc": "CwoAdmin",
            "pw": "P@ssw0rd",
            "version":"",
            "widget_threedots": ".icon.icon-three-dots.icon-40",
            "opt1": "1f07e4c4-a849-4c72-8a55-24eaeabca923",
            "opt2": "b516d54e-bd37-4710-a11f-ffebc06ed677",
            "node_id": "VTP-0001"
        },
        "combobox_variables": [],
        "combobox_options": {}
    },
    "EMS_Stage":{
        "variables":{
            "url": "https://stage.ihouseems.com/web/NewEnergyStorage/ihouseEMS/login.html",
            "org": "TestCwo",
            "acc": "TestAdmin",
            "pw": "P@ssw0rd",
            "version":"",
            "widget_threedots": ".icon.icon-three-dots.icon-40.float-end",
            "opt1": "179bafaf-e5c2-42e4-b9b3-e0e3fb5fa636",
            "opt2": "2bfd8f82-8c10-452b-90ab-b6d894311d91",
            "node_id": "VTP-0001"
        },
        "combobox_variables": [],
        "combobox_options": {}
    },
    "ACER": {
        "variables": {
            "url": "http://192.168.11.157/",
            "acc": "admin",
            "pw": "P@ssw0rd",
            "version":"",
            "department": "自動化工具專用>組織",
            "device_id": "13F-VRF-AC-B5-35-F",
            "node_id":  "TempSet",
            "trigger_timing_start": "00:00",
            "trigger_timing_end": "00:00"
        },
        "combobox_variables": [],
        "combobox_options": {}
    },
    "LA": {
        "variables": {
            "url": "http://192.168.11.88/ihouseBA/",
            "acc": "admin",
            "pw": "P@ssw0rd",
            "version":"",
            "uid": "61de9c98-a9b6-4756-9de8-0b4907ae5ef7",
            "device1": "0CFE5DEF6376",
            "device2": "0CFE5DEF6376-1"
        },
        "combobox_variables": ["uid"],
        "combobox_options": {
            "uid": ["61de9c98-a9b6-4756-9de8-0b4907ae5ef7"]
        }
    },
    "BMS":{
        "variables":{
            "url" :"http://192.168.11.180/",
            "acc" :"admin",
            "pw": "P@ssw0rd",
            "version":"",
            "device_id": "請選擇，widget、trigger建立使用",
            "node_id":  "TempSet",
            "trigger_timing_start": "00:00",
            "trigger_timing_end": "00:00"
        },
        "combobox_variables": ["url", "device_id"],
        "combobox_options": {
            "url": ["http://192.168.11.180/", "http://192.168.11.151/", "http://192.168.11.152/", "http://192.168.11.153/", "http://192.168.11.154/", "http://192.168.11.155/", "http://192.168.11.156/"],
            "device_id": ["13F-VRF-AC-B5-35-F"]
        }
    }
}
