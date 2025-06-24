import os.path
import sys
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List
import subprocess
import logging
import asyncio
from datetime import datetime

active_mqtt_simulators = {}

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)
# 定義 API 請求體資料的模型 (接收 address, device_id)
class MqttTrigger(BaseModel):
    """模擬器觸發的請求資料模型"""
    broker_address: str = Field(..., min_length=1, description="MQTT broker 的IP位址或域名")
    topic: str = Field('com/cwo/general_gw001/report/', description="要發送消息的 MQTT Topic")
    broker_port: int = Field(1884, gt=0, description="MQTT broker 的端口")
    device_id: List[str] = Field(['d1', 'd2', 'd3'], min_length=1, description="要發送消息的裝置 ID 列表")
    value: int = Field(0, ge=0, description="要發送的起始數值")
    status: int = Field(1, description="裝置狀態 (預設為 1)")
    seconds: int = Field(60, gt=0, description="發送間隔(秒), 預設 60 秒")

app = FastAPI(title="MQTT Trigger API", version="1.0",
              description="""
**用於管理和控制多個 MQTT 設備模擬器的 API 服務**

---

## 🚀 功能
- 啟動/停止 MQTT 模擬器
- 查詢運行狀態  
- 多設備並行模擬

## ⚠️ 注意
確保 `device.py` 存在，避免過多模擬器同時運行""")

@app.post("/trigger-mqtt", summary="啟動 MQTT 模擬器",
          description="""
啟動新的 MQTT 設備模擬器進程，支援多設備並行模擬

#### 輸入必要資訊  
- **broker_address** - 目標環境位址
- **device_id** - 模擬的設備 ID
          """)
async def trigger_message(trigger_data: MqttTrigger):
    """
    觸發 MQTT 模擬器並向指定 Topic 發送消息。
    此端點接收 MQTT 代理的連線資訊、目標 Topic 、裝置 ID 列表、
    起始數值以及發送間隔，然後啟動一個外部模擬器程序來發送模擬數據。
    Args:
        trigger_data (MqttTrigger): 包含 broker 地址、裝置 ID
    """
    py_path = sys.executable
    script_path = os.path.join(os.path.dirname(__file__), "device.py")
    if not os.path.exists(script_path):
        logger.error(f"{script_path}找不到目標檔案 - device.py")
        raise HTTPException(status_code=500, detail="服務錯誤，找不到檔案，請確認檔案是否存在目錄")
    try:
        device_ids_str = ",".join(trigger_data.device_id)

        cmd = [
            py_path,
            script_path,
            "--broker-address", trigger_data.broker_address,
            "--broker-port", str(trigger_data.broker_port),
            "--topic", trigger_data.topic,
            "--device-id", device_ids_str,  # 使用傳入的string(已用,分割deviceid的list)
            "--initial-value", str(trigger_data.value),
            "--interval", str(trigger_data.seconds)
        ]

        logger.info(f"Executing command: {' '.join(cmd)}")
        # 使用 subprocess.Popen 非阻塞地啟動外部程序
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        await asyncio.sleep(0.5)

        result = process.poll()
        if result is not None and result != 0:
            stdout, stderr = process.communicate()
            logger.error(f"MQTT 模擬器啟動失敗: {stderr}")
            raise HTTPException(status_code=500, detail=f"MQTT 模擬器執行失敗: {stderr}")
        active_mqtt_simulators[process.pid] = {
            'process': process,
            'start_time': datetime.now(),
            'broker': f"{trigger_data.broker_address}:{trigger_data.broker_port}",
            'device_id': trigger_data.device_id
        }
        logger.info(f"MQTT 模擬器執行成功, PID: {process.pid}")

        return {
            "message": "MQTT simulator started successfully",
            "broker": f"{trigger_data.broker_address}:{trigger_data.broker_port}",
            "topic": f"{trigger_data.topic}",
            "device_id": trigger_data.device_id,
            "value": trigger_data.value,
            "status": trigger_data.status,
            "pid": process.pid
        }

    except subprocess.TimeoutExpired:
        logger.error("MQTT 模擬器執行超時")
        raise HTTPException(status_code=504, detail="MQTT 模擬器執行超時")
    except Exception as e:
        logger.error(f"處理請求時發生預期外錯誤: {e}")
        raise HTTPException(status_code=500, detail=f"處理請求時發生預期外錯誤: {str(e)}")

@app.get("/simulators-list", summary="查詢運行中的模擬器",description="""
**查詢所有執行中的 MQTT 模擬器**

#### 回傳資訊
- **PID** - 進程識別碼
- **啟動時間** - 開始運行時間  
- **Broker** - 連接地址
- **設備列表** - 模擬的設備 ID
- **狀態** - 是否正在運行
""")
async def list_simulators():
    """
    列出當前所有本服務啟動且運行中的MQTT模擬器進程
    Returns:
    此服務現在運行中的電表模擬器
    """
    process_to_remove = []
    for pid, info in active_mqtt_simulators.items():
        if info['process'].poll() is not None:
            process_to_remove.append(pid)

    for pid in process_to_remove:
        del active_mqtt_simulators[pid]

    running_simulators = []
    for pid, info in active_mqtt_simulators.items():
        running_simulators.append({
            "pid": pid,
            "start_time": info['start_time'],
            "broker": info['broker'],
            "device_id": info['device_id'],
            "is_running": info['process'].poll() is None
        })

    running_simulators.sort(key=lambda x:x['pid'])

    return {
        "message": "running MQTT simulators",
        "count": len(running_simulators),
        "simulators": running_simulators
    }

@app.delete("/stop-simulator/{pid}", summary="停止指定的模擬器", description="")
async def stop_simulator(pid: int):
    """停止指定的MQTT模擬器"""
    if pid not in active_mqtt_simulators:
        raise HTTPException(status_code=404, detail=f"此服務找不到PID為 {pid} 的模擬器，請確認他是否正在運行")

    process_info = active_mqtt_simulators[pid]
    process = process_info['process']

    try:
        if process.poll() is None:
            process.terminate()
            await asyncio.sleep(1)

            if process.poll() is None:
                process.kill()
            process.wait(timeout=5)
        logger.info(f"成功終止 {pid}")
        del active_mqtt_simulators[pid]
        return {"message": f"MQTT {pid}模擬器已停止"}
    except subprocess.TimeoutExpired:
        logger.error(f"{pid}終止超時")
        raise HTTPException(status_code=500, detail=f"終止{pid}超時")
    except Exception as e:
        logger.error(f"{pid}終止時發生錯誤: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"{pid}終止時發生未知錯誤")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)