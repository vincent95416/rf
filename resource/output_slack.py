import requests
import json
from robot.api import ExecutionResult
import xml.etree.ElementTree as ET

def exe_output():
    # 這裡替換成你的 webhook URL
    webhook_url = 'https://hooks.slack.com/services/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'

    # 設定 output.xml 的路徑
    output_file_path = '../robot_results/output.xml'
    # 解析 output.xml 檔案
    result = ExecutionResult(output_file_path)
    # 獲得執行時間,單位為秒
    execution_time = result.suite.elapsedtime / 1000
    stats = result.statistics
    tree = ET.parse(output_file_path)
    root = tree.getroot()

    version = 'N/A'
    environment = 'N/A'
    for msg in root.findall(".//msg"):
        if "Testing version" in msg.text:
            parts = msg.text.split()
            version = parts[2]    # msg中第二個字節
            environment = parts[4]    # msg中第四個字節
            break
    slack_data = {
        'text':
            f"總測試案例: {stats.total.total}\n"
            f"通過數: {stats.total.passed}\n"
            f"失敗數: {stats.total.failed}\n"
            f"版本: {version}\n"
            f"環境: {environment}\n"
            f"執行時間: {execution_time:.2f} 秒\n"
    }

    # 發送 POST 請求
    response = requests.post(
        webhook_url, data=json.dumps(slack_data),
        headers={'Content-Type': 'application/json'}
    )

    # 驗證回應
    if response.status_code == 200:
        print('Message posted successfully.')
    else:
        print(f'Failed to post message. Status code: {response.status_code}')

if __name__ == "__main__":
    try:
        exe_output()
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        import traceback
        print(traceback.format_exc())
        exit(1)