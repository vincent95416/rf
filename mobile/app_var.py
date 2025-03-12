# 固定變數 (系統參數)
APPIUM_URL = "http://127.0.0.1:4723"
PLATFORM_NAME = "Android"
AUTOMATION_NAME = "UiAutomator2"
#DEVICE_NAME = "RFCNA0X8KAF"
APP_PACKAGE = "com.kt.aihome"
APP_ACTIVITY = "com.example.kbro.MainActivity"
INSTALL_TIME = 60000

# 使用者變數預設值 (GUI 介面預設值)
USER_VAR_DEFAULTS = {
    "username": "0984123725",
    "password": "password",
    "title": "stage橘子居家",
    "cam_skywatch": "測8C:51:09:D1:02:C4",
    "cam_nvr": "ALSTI5KL23370661",
    "c1_name": "奧創智慧開關testben",
    "version": "",
    "DEVICE_NAME": ""
}



COMBOBOX_VARIABLES = ["DEVICE_NAME", "cam_nvr", "cam_skywatch"]

COMBOBOX_OPTIONS = {
    "DEVICE_NAME": ["RFCNA0X8KAF", "2A181FDH200KK1"],
    "cam_nvr": ["ALSTI5KL23370661", "ALN3E5FG24250005", "ALSTI5KG23390157"],
    "cam_skywatch": ["測8C:51:09:D1:05:6A", "測8C:51:09:D1:02:C4"]
}

ENVIRONMENTS = ["凱擘居家APP(Stage)", "凱擘居家APP(Production)"]    #環境列表