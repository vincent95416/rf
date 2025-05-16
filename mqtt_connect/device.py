import random
import paho.mqtt.client as mqtt
import time
import datetime
import json
import argparse
import sys

# broker_address = '192.168.11.102'
# broker_port = 1884
# broker_topic = 'com/cwo/general_gw001/report/'

def generate_id():
    return f"mqtt_client_{random.randint(100,999)}"

def on_connect(client, userdata, flags, reason_code, properties=None):
    if reason_code == 0:
        print(f'成功連線到broker, {userdata[0]}, client_ID : {userdata[1]}')
        # client.subscribe(broker_topic)
    else:
        print(f'連線失敗, {reason_code}')

def on_message(client, userdata, message):
    print(f'收到消息, 來自Topic {message.topic}, 內容 : {message.payload.decode()}')

def publish(client, topic, message):
    try:
        result = client.publish(topic, message)
        if result[0] == 0:
            print(f"成功發布消息到Topic '{topic}'")
        else:
            print(f"發布失敗, {result}[0]")
    except Exception as e:
        print(f'發布消息時發生預期外錯誤 {e}')

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

def main():
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

    try:
        client.connect(broker_address, broker_port)
    except Exception as e:
        print(f'連線失敗，發生錯誤 : {e}')
        sys.exit(1)

    client.loop_start()

    # devices = ['dv_001', 'dv_002', 'dv_003']
    # start_value = 0
    vals = {device: start_value for device in device_ids}
    try:
        while True:
            for device in device_ids:
                vals[device] += 1
                #current_value = vals[device]
                message_vals = {
                    "kwh": vals[device]
                }
                status = 1
                message = create_message(device, message_vals, status)
                #print(message)
                publish(client, (topic + device), message)
            time.sleep(interval)
    except Exception as e:
        print(f"\n模擬器發生錯誤: {e}")
    finally:
        client.loop_stop()
        client.disconnect()
        sys.exit(0)

if __name__ == '__main__':
    main()