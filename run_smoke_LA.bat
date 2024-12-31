:: 提高可讀性,隱藏回顯輸出
@echo off
:: 設置編碼為 UTF-8
chcp 65001
:: 切換到批次檔所在的目錄
cd /d %~dp0

:: 執行 Robot Framework 測試
robot --outputdir ".\robot_results" ".\smoke_LA"

:: 切換到 robot_results 目錄
cd .\robot_results

:: 檢查是否成功產生 output.xml
if exist "output.xml" (
    echo 測試完成，發送 Slack 通知
    :: 執行 Python 腳本來處理結果並發送通知
    call python ..\resource\output_slack.py
) else (
    echo 未生成 output.xml
    exit /b 1
)