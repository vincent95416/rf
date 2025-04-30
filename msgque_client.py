import random
import paho.mqtt.client as mqtt
import time
import datetime

broker_address = '192.168.11.23'
broker_port = 1884
broker_topic = 'com/cwo/ba/event/D4CFF9A3C4F0'

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

def main():
    client_id = generate_id()

    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id)
    client.on_connect = on_connect
    client.on_message = on_message

    client.user_data_set(client_id)

    try:
        client.connect(broker_address, broker_port)
    except Exception as e:
        print('連線失敗，發生錯誤 : {e}')

    client.loop_start()

    while True:
        now = datetime.datetime.now()
        timestamp_str = now.strftime("%Y/%m/%d %H:%M:%S")
        message = f"Hello, this is from {client_id}, 在 {timestamp_str}"
        publish(client, broker_topic, message)
        time.sleep(60)

if __name__ == '__main__':
    main()