import random
import paho.mqtt.client as mqtt
import time
import datetime
import json
import argparse
import sys
import os
import logging
from pydantic import BaseModel, Field, ValidationError # 新增 ValidationError
from typing import Optional, Dict

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler(f'mqtt_device_{datetime.datetime.now().strftime("%Y%m%d_%H%M%S")}.log')
    ]
)
logger = logging.getLogger(__name__)

is_connected = False
connection_count = 0
last_disconnect_time = None

class FormulaParameter(BaseModel):
    base: float
    range: float = Field(..., ge=0)

class FormulaConfig(BaseModel):
    # 基礎電力參數 - 全部設為可選，預設 None
    kwh: Optional[FormulaParameter] = None
    freq: Optional[FormulaParameter] = None
    iA: Optional[FormulaParameter] = None
    iB: Optional[FormulaParameter] = None
    iC: Optional[FormulaParameter] = None
    PFTotal: Optional[FormulaParameter] = None
    vlnA: Optional[FormulaParameter] = None
    vlnB: Optional[FormulaParameter] = None
    vlnC: Optional[FormulaParameter] = None
    vllAB: Optional[FormulaParameter] = None
    vllBC: Optional[FormulaParameter] = None
    vllCA: Optional[FormulaParameter] = None

def generate_id():
    return f"mqtt_client_{random.randint(100,999)}"

def on_connect(client, userdata, flags, reason_code, properties=None):
    global is_connected
    if reason_code == 0:
        is_connected = True
        logger.info(f'成功連線到broker, {userdata[0]}, client_ID : {userdata[1]}')
        # client.subscribe(broker_topic)
    else:
        is_connected = False
        logger.error(f'連線失敗, {reason_code}')

def on_disconnect(client, userdata, flags, reason_code, properties=None):
    global is_connected, connection_count
    is_connected = False
    connection_count += 1
    last_disconnect_time = datetime.datetime.now()
    if reason_code == 0:
        logger.info('MQTT Server結束連線')
    else:
        is_connected = False
        logger.error(f'異常斷線 ! reason_code: {reason_code}, 次數: {connection_count}')
        logger.info(f'斷線時間: {last_disconnect_time.strftime("%Y-%m-%d %H:%M:%S")}')

def on_log(client, userdata, level, buf):
    log_levels = {
        mqtt.MQTT_LOG_INFO: logger.info,
        mqtt.MQTT_LOG_NOTICE: logger.info,
        mqtt.MQTT_LOG_WARNING: logger.warning,
        mqtt.MQTT_LOG_ERR: logger.error,
        mqtt.MQTT_LOG_DEBUG: logger.debug
    }
    log_function = log_levels.get(level, logger.info)
    log_function(f'MQTT Client: {buf}')

def on_message(client, userdata, message):
    print(f'收到消息, 來自Topic {message.topic}, 內容 : {message.payload.decode()}')

def publish(client, topic, message):
    try:
        if not is_connected:
            logger.warning('尚未連線到server，無法發布消息')
            return False

        result = client.publish(topic, message)
        if result[0] == 0:
            logger.debug(f'成功發布消息到Topic {topic}')
            return True
        else:
            logger.error(f"發布失敗, {result[0]}")
            return False
    except Exception as e:
        logger.error(f'發生預期外錯誤 {e}, 無法發布消息')
        return False

def create_message(device, vals_dict, status):
    now = datetime.datetime.now()
    timestamp = int(now.timestamp())
    message_dict = {
        "vals": {
            device: {
                "vals": vals_dict,
                "status": status
            }
        },
        "timestamp": timestamp
    }
    message = json.dumps(message_dict, ensure_ascii=False, indent=4)
    return message

def wait_for_connection(client):
    global is_connected
    if is_connected:
        return True

    logger.info('開始重連...')
    for attempt in range(1, 11):
        try:
            logger.info(f'重連嘗試 {attempt}/10')

            # 使用遞增延遲，但不要太複雜
            delay = min(attempt * 2, 30)  # 最多等待 30 秒
            time.sleep(delay)

            client.reconnect()

            # 等待連線狀態更新
            wait_time = 5
            start_time = time.time()
            while not is_connected and (time.time() - start_time) < wait_time:
                time.sleep(0.1)
            if is_connected:
                logger.info(f'重連成功! (第 {attempt} 次嘗試)')
                return True
        except Exception as e:
            logger.error(f'重連嘗試 {attempt} 失敗: {e}')
    logger.error('嘗試後仍無法重連')
    return False

def get_random_value(param: FormulaParameter):
    """根據 FormulaParameter 生成隨機值"""
    return param.range * random.random()

def main():
    global is_connected, connection_count
    # --- 解析參數 ---
    parser = argparse.ArgumentParser(description='MQTT Simulator Script')
    parser.add_argument('--broker-address', type=str, help='Broker Address')
    parser.add_argument('--broker-port', type=int, default=1884, help='Broker Port')
    parser.add_argument('--topic', type=str, default='com/cwo/general_gw001/report/', help='Topic (default: com/cwo/general_gw001/report/)')
    parser.add_argument('--device-id', type=str, required=True, help='list of Device ID (e.g. dev001, dev002)')
    parser.add_argument('--interval', type=int, default=60, help='Sending interval in seconds(default: 60)')
    parser.add_argument('--formula', type=str, default='{}', help='Json string of formula configuration')

    args = parser.parse_args()

    broker_address = args.broker_address
    broker_port = args.broker_port
    topic = args.topic
    device_ids = [d.strip() for d in args.device_id.split(',') if d.strip()]
    interval = args.interval
    formula = FormulaConfig()
    try:
        if args.formula != '{}':
            formula_data = json.loads(args.formula)
            formula = FormulaConfig(**formula_data)
    except json.JSONDecodeError as e:
        logger.error(f"解析formula參數失敗: {e}")
        sys.exit(1)
    except ValidationError as e:
        logger.error(f"FormulaConfig 格式錯誤: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"初始化FormulaConfig發生錯誤: {e}")
        sys.exit(1)

    if not broker_address:
        print('錯誤: 必須提供broker的host')
        sys.exit(1)
    if not device_ids:
        print('錯誤: 必須至少提供一個device id')
        sys.exit(1)


    client_id = generate_id()
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id)
    client.on_connect = on_connect
    client.on_message = on_message
    client.user_data_set((f"{broker_address}:{broker_port}", client_id))

    client.reconnect_delay_set(min_delay=1, max_delay=120)
    # 初始連線
    try:
        client.connect(broker_address, broker_port)
    except Exception as e:
        print(f'初始連線失敗，發生錯誤 : {e}')
        sys.exit(1)

    client.loop_start()

    vals: Dict[str, Dict[str, float]] = {device: {} for device in device_ids}

    for device in device_ids:
        vals[device]["kwh"] = formula.kwh.base if formula.kwh else 0.0
        vals[device]["freq"] = formula.freq.base if formula.freq else 0.0
        vals[device]["iA"] = formula.iA.base if formula.iA else 0.0
        vals[device]["iB"] = formula.iB.base if formula.iB else 0.0
        vals[device]["iC"] = formula.iC.base if formula.iC else 0.0
        vals[device]["PFTotal"] = formula.PFTotal.base if formula.PFTotal else 0.0
        vals[device]["vlnA"] = formula.vlnA.base if formula.vlnA else 0.0
        vals[device]["vlnB"] = formula.vlnB.base if formula.vlnB else 0.0
        vals[device]["vlnC"] = formula.vlnC.base if formula.vlnC else 0.0
        vals[device]["vllAB"] = formula.vllAB.base if formula.vllAB else 0.0
        vals[device]["vllBC"] = formula.vllBC.base if formula.vllBC else 0.0
        vals[device]["vllCA"] = formula.vllCA.base if formula.vllCA else 0.0

    try:
        while True:
            if not wait_for_connection(client):
                logger.error('無法建立連線，停止程序')
                break
            for device in device_ids:
                message_vals = {}
                status = 1

                if formula.kwh:
                    vals[device]["kwh"] += get_random_value(formula.kwh)
                    message_vals["kwh"] = vals[device]["kwh"]

                if formula.freq:
                    vals[device]["freq"] += get_random_value(formula.freq)
                    message_vals["freq"] = vals[device]["freq"]

                iA_val = None
                iB_val = None
                iC_val = None
                if formula.iA:
                    vals[device]["iA"] += get_random_value(formula.iA)
                    iA_val = vals[device]["iA"]
                    message_vals["iA"] = iA_val
                if formula.iB:
                    vals[device]["iB"] += get_random_value(formula.iB)
                    iB_val = vals[device]["iB"]
                    message_vals["iB"] = iB_val
                if formula.iC:
                    vals[device]["iC"] += get_random_value(formula.iC)
                    iC_val = vals[device]["iC"]
                    message_vals["iC"] = iC_val

                PFTotal_val = None
                if formula.PFTotal:
                    vals[device]["PFTotal"] += get_random_value(formula.PFTotal)
                    PFTotal_val = vals[device]["PFTotal"]
                    message_vals["PFTotal"] = PFTotal_val

                vlnA_val = None
                vlnB_val = None
                vlnC_val = None
                if formula.vlnA:
                    vals[device]["vlnA"] += get_random_value(formula.vlnA)
                    vlnA_val = vals[device]["vlnA"]
                    message_vals["vlnA"] = vlnA_val
                if formula.vlnB:
                    vals[device]["vlnB"] += get_random_value(formula.vlnB)
                    vlnB_val = vals[device]["vlnB"]
                    message_vals["vlnB"] = vlnB_val
                if formula.vlnC:
                    vals[device]["vlnC"] += get_random_value(formula.vlnC)
                    vlnC_val = vals[device]["vlnC"]
                    message_vals["vlnC"] = vlnC_val

                # 計算 wA, wB, wC, wSum
                if iA_val is not None and vlnA_val is not None and PFTotal_val is not None:
                    message_vals["wA"] = iA_val * vlnA_val * PFTotal_val
                if iB_val is not None and vlnB_val is not None and PFTotal_val is not None:
                    message_vals["wB"] = iB_val * vlnB_val * PFTotal_val
                if iC_val is not None and vlnC_val is not None and PFTotal_val is not None:
                    message_vals["wC"] = iC_val * vlnC_val * PFTotal_val

                if "wA" in message_vals and "wB" in message_vals and "wC" in message_vals:
                    message_vals["wSum"] = message_vals["wA"] + message_vals["wB"] + message_vals["wC"]

                vllAB_val = None
                vllBC_val = None
                vllCA_val = None
                if formula.vllAB:
                    vals[device]["vllAB"] += get_random_value(formula.vllAB)
                    vllAB_val = vals[device]["vllAB"]
                    message_vals["vllAB"] = vllAB_val
                if formula.vllBC:
                    vals[device]["vllBC"] += get_random_value(formula.vllBC)
                    vllBC_val = vals[device]["vllBC"]
                    message_vals["vllBC"] = vllBC_val
                if formula.vllCA:
                    vals[device]["vllCA"] += get_random_value(formula.vllCA)
                    vllCA_val = vals[device]["vllCA"]
                    message_vals["vllCA"] = vllCA_val

                if vllAB_val is not None and vllBC_val is not None and vllCA_val is not None:
                    message_vals["vllAvg"] = (vllAB_val + vllBC_val + vllCA_val) / 3

                if iA_val is not None and iB_val is not None and iC_val is not None:
                    message_vals["iAvg"] = (iA_val + iB_val + iC_val) / 3

                if not message_vals:
                    logger.warning(f"沒有為設備 {device} 配置任何公式參數，不發送訊息。")
                    continue

                message = create_message(device, message_vals, status)
                publish(client, (topic + device), message)
            time.sleep(interval)
    except Exception as e:
        logger.info(f"\n模擬器發生錯誤: {e}")
    finally:
        client.loop_stop()
        client.disconnect()
        sys.exit(0)

if __name__ == '__main__':
    main()