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
            "url": "http://192.168.11.123/ihouseBA/login.html",
            "acc": "admin",
            "pw": "P@ssw0rd",
            "version":"",
            "init_label": "13-1",
            "device1": "0CFE5DEF6376",    #widget設定用
            "device2": "_devGroup1-VTE-0047",
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
            "url" :"http://192.168.11.22/ihouseBA/login.html",
            "acc" :"admin",
            "pw": "P@ssw0rd",
            "version":"",
        },
        "combobox_variables": ["url"],
        "combobox_options": {
            "url" : ["http://192.168.11.22/ihouseBA/login.html", "http://192.168.11.26/ihouseBA/login.html"]
        }
    }
}
