import random
import paho.mqtt.client as mqtt
import time
import datetime
import json
broker_address = '192.168.11.102'
broker_port = 1884
broker_topic = 'com/cwo/general_gw001/report/'

def generate_id():
    return f"P_{random.randint(100,999)}"

def on_connect(client, userdata, flags, reason_code, properties=None):
    if reason_code == 0:
        print(f'成功連線到broker, {broker_address}, client_ID : {userdata}')
        client.subscribe(broker_topic)
    else:
        print(f'連線失敗, {reason_code}')

def on_message(client, userdata, message):
    print(f'收到消息, 來自Topic {message.topic}, 內容 : {message.payload.decode()}')

def publish(client, topic, message):
    try:
        result = client.publish(topic, message)
        if result[0] == 0:
            print(f"成功發布消息 '{message}' 到Topic '{topic}'")
        else:
            print(f"發布失敗, {result}[0]")
    except Exception as e:
        print(f'發布消息時發生預期外錯誤 {e}')
        print('5秒後嘗試重新連線...')
        client.reconnect()
        time.sleep(5)

def create_message(device, vals_dict, status):
    now = datetime.datetime.now()
    timestamp = int(now.timestamp())  # Convert to milliseconds
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
    client_id = generate_id()

    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id)
    client.on_connect = on_connect
    client.on_message = on_message

    client.user_data_set(client_id)

    try:
        client.connect(broker_address, broker_port)
    except Exception as e:
        print(f'連線失敗，發生錯誤 : {e}')

    client.loop_start()

    devices = ['dv_001', 'dv_002', 'dv_003']
    start_value = 0
    vals = {device: start_value for device in devices}

    while True:
        for device in devices:
            vals[device] += 1
            message_vals = {
                "kwh": vals[device]
            }
            status = 1
            message = create_message(device, message_vals, status)
            print(message)
            publish(client, (broker_topic + device), message)
        time.sleep(20)

if __name__ == '__main__':
    main()
