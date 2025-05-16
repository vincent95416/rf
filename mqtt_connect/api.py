from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List
import subprocess
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)
# 定義 API 請求體資料的模型 (接收 topic, device_id, value)
class MqttTrigger(BaseModel):
    broker_address: str = Field(..., min_length=1, description="MQTT broker 的地址")
    topic: str = Field('com/cwo/general_gw001/report/', description="要發送消息的 MQTT Topic 前綴")
    broker_port: int = Field(1884, gt=0, description="MQTT broker 的端口")
    device_id: List[str] = Field(['d1', 'd2', 'd3'], min_length=1, description="要發送消息的裝置 ID 列表")
    value: int = Field(0, gt=0, description="要發送的起始數值")
    status: int = Field(1, description="裝置狀態 (預設為 1)")
    seconds: int = Field(60, gt=0, description="發送間隔(秒), 預設 60 秒")

app = FastAPI(title="MQTT Trigger API", version="1.0", )

@app.post("/trigger-mqtt")
async def trigger_message(trigger_data: MqttTrigger):
    """
    觸發 MQTT 模擬器並向指定 Topic 發送消息。
    此端點接收 MQTT 代理的連線資訊、目標 Topic 前綴、裝置 ID 列表、
    起始數值以及發送間隔，然後啟動一個外部模擬器程序來發送模擬數據。
    Args:
        trigger_data (MqttTrigger): 包含 broker 地址、裝置 ID 和要發送的數值
    Returns:
        dict: 表示消息已觸發的確認信息
    """
    try:
        device_ids_str = ",".join(trigger_data.device_id)

        cmd = [
            "python", "device.py",
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

        stdout, stderr = process.communicate(timeout=10)

        if process.returncode != 0:
            logger.error(f"MQTT 模擬器啟動失敗: {stderr}")
            raise HTTPException(status_code=500, detail=f"MQTT 模擬器執行失敗: {stderr}")

        logger.info(f"MQTT 模擬器執行成功: {stdout}")

        return {
            "message": "MQTT message trigger successfully",
            "broker": f"{trigger_data.broker_address:{trigger_data.broker_port}}",
            "topic": f"{trigger_data.topic}{trigger_data.device_id}",
            "device_id": trigger_data.device_id,
            "value": trigger_data.value,
            "status": trigger_data.status
        }

    except subprocess.TimeoutExpired:
        logger.error("MQTT 模擬器執行超時")
        raise HTTPException(status_code=504, detail="MQTT 模擬器執行超時")
    except Exception as e:
        logger.error(f"處理請求時發生預期外錯誤: {e}")
        raise HTTPException(status_code=500, detail=f"處理請求時發生預期外錯誤: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)