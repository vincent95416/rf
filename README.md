此專案是圍繞 Robot Framework、Pytest 與其他腳本建立的自動化測試與工具集合。

## 專案結構

* `/resource/`: Web 自動化 (Robot Framework + Playwright)，包含一個啟動 (`web_gui.py`)。
* `/mobile/`: App 自動化 (Robot Framework + Appium)，包含一個啟動器 (`gui.py`)。
* `/mqtt_connect/`: 一個 FastAPI 服務 (`api.py`)，用於啟動與管理 MQTT 設備模擬器 (`device.py`)。
* `/testcase/`: API 整合測試 (Pytest)。
* `/line_regression_study/`: 用於數據分析的線性迴歸腳本。


1.  **安裝主要依賴套件：**
    ```
    pip install -r requirements.txt
    ```
	
2.  **啟動不同工具：**

    * **Web 測試啟動器:**
        ```
        python resource/web_gui.py
        ```

    * **App 測試啟動器:**
        ```
        python mobile/gui.py
        ```

    * **MQTT 模擬器服務:**
        ```
        # 僅需安裝 FastAPI 相關套件
        pip install -r mqtt_connect/requie.txt
        # 啟動 API 服務
        uvicorn mqtt_connect.api:app --reload
        ```
        服務啟動後，請至 `http://localhost:8000/docs` 查看 API 文件。

    * **BMS API 測試:**
        ```
        pytest testcase/bms/v1tests/
        ```
	*

## 設定與環境文件

* **Web 測試環境:** `resource/environment_variables.py`
* **App 測試環境:** `mobile/app_var.py`
* **BMS API 測試環境:** `testcase/bms/v1tests/conf_test.py`