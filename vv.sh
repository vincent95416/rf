#!/bin/bash

# 執行Robot Framework測試
echo "開始執行Robot Framework測試..."
robot --outputdir ./robot_results ./testcase/Basic.robot

# 檢查是否成功產生 output.xml
if [ -f ./robot_results/output.xml ]; then
    echo "測試完成，開始發送通知"
    # 執行Python腳本來處理結果並發送通知
    python3 ./resource/output_slack.py
else
    echo "未生成output.xml"
    exit 1
fi
