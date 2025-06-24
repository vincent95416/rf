import random
import paho.mqtt.client as mqtt
import time
import datetime
import json
import argparse
import sys
import os
import logging

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

def main():
    global is_connected, connection_count
    # --- 解析參數 ---
    parser = argparse.ArgumentParser(description='MQTT Simulator Script')
    parser.add_argument('--broker-address', type=str, help='Broker Address')
    parser.add_argument('--broker-port', type=int, default=1884, help='Broker Port')
    parser.add_argument('--topic', type=str, default='com/cwo/general_gw001/report/', help='Topic (default: com/cwo/general_gw001/report/)')
    parser.add_argument('--device-id', type=str, required=True, help='list of Device ID (e.g. dev001, dev002)')
    parser.add_argument('--initial-value', type=int, default=0, help='Initial value for device(default: 0)')
    parser.add_argument('--interval', type=int, default=60, help='Sending interval in seconds(default: 60)')

    args = parser.parse_args()

    broker_address = args.broker_address
    broker_port = args.broker_port
    topic = args.topic
    device_ids = [d.strip() for d in args.device_id.split(',') if d.strip()]
    start_value = args.initial_value
    interval = args.interval

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
    # 等待初始連線
    if not wait_for_connection(client):
        logger.error('初始重連失敗: {e}')
        sys.exit(1)

    vals = {device: start_value for device in device_ids}
    try:
        while True:
            if not wait_for_connection(client):
                logger.error('無法建立連線，停止程序')
                break
            for device in device_ids:
                vals[device] += random.random()
                freq = 2 * random.random() + 58
                iA = 5 * random.random() + 10
                iB = 5 * random.random() + 10
                iC = 5 * random.random() + 10
                PFTotal = 0.1 * random.random() + 0.9
                vlnA = 5 * random.random() + 110
                vlnB = 5 * random.random() + 110
                vlnC = 5 * random.random() + 110
                wA = iA * vlnA * PFTotal
                wB = iB * vlnB * PFTotal
                wC = iC * vlnC * PFTotal
                wSum = wA + wB + wC
                vllAB = 5 * random.random() + 220
                vllBC = 5 * random.random() + 220
                vllCA = 5 * random.random() + 220
                vllAvg = (vllAB + vllBC + vllCA) / 3
                iAvg = (iA + iB + iC) / 3
                message_vals = {
                    "kwh": vals[device],
                    "freq": freq,
                    "iA": iA,
                    "iB": iB,
                    "iC": iC,
                    "PFTotal": PFTotal,
                    "vlnA": vlnA,
                    "vlnB": vlnB,
                    "vlnC": vlnC,
                    "wA": wA,
                    "wB": wB,
                    "wC": wC,
                    "wSum": wSum,
                    "vllAB": vllAB,
                    "vllBC": vllBC,
                    "vllCA": vllCA,
                    "vllAvg": vllAvg,
                    "iAvg": iAvg
                }
                status = 1
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