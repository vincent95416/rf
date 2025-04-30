import redis
import json
import argparse
import os

def dump_redis(r, output_file):
    data = {}
    cursor = 0

    while True:
        cursor, keys = r.scan(cursor=cursor, count=100)
        for key in keys:
            key_type = r.type(key)
            try:
                if key_type == 'string':
                    data[key] = r.get(key)
                elif key_type == 'list':
                    data[key] = r.lrange(key, 0, -1)
                elif key_type == 'set':
                    data[key] = list(r.smembers(key))
                elif key_type == 'zset':
                    data[key] = r.zrange(key, 0, -1, withscores=True)
                elif key_type == 'hash':
                    data[key] = r.hgetall(key)
                else:
                    data[key] = f"<Unsupported type: {key_type}>"
            except Exception as e:
                data[key] = f"<Error: {str(e)}>"

        if cursor == 0:
            break

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"✅ Dump 完成，共匯出 {len(data)} 筆資料到 {output_file}")

def restore_redis(r, input_file):
    if not os.path.exists(input_file):
        print(f"❌ 找不到檔案: {input_file}")
        return

    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    for key, value in data.items():
        r.delete(key)

        if isinstance(value, str):
            r.set(key, value)
        elif isinstance(value, list):
            if all(isinstance(v, list) and len(v) == 2 and isinstance(v[1], (int, float)) for v in value):
                r.zadd(key, {v[0]: v[1] for v in value})
            else:
                r.rpush(key, *value)
        elif isinstance(value, dict):
            r.hset(key, mapping=value)
        else:
            print(f"⚠️ 跳過無法辨識的格式: {key}")

    print(f"✅ 還原完成，共匯入 {len(data)} 筆資料")

def main():
    parser = argparse.ArgumentParser(description="Redis JSON 匯入/匯出工具")
    parser.add_argument('--host', default='localhost', help='Redis 主機 (預設: localhost)')
    parser.add_argument('--port', type=int, default=6379, help='Redis 連接埠 (預設: 6379)')
    parser.add_argument('--dump', action='store_true', help='執行 dump 匯出作業')
    parser.add_argument('--restore', action='store_true', help='執行還原作業')
    parser.add_argument('--out', default='redis_dump.json', help='輸出檔案路徑 (預設: redis_dump.json)')
    parser.add_argument('--in', dest='infile', default='redis_dump.json', help='輸入檔案路徑 (預設: redis_dump.json)')

    args = parser.parse_args()

    r = redis.Redis(host=args.host, port=args.port, decode_responses=True)

    if args.dump:
        dump_redis(r, args.out)
    elif args.restore:
        restore_redis(r, args.infile)
    else:
        print("⚠️ 請指定 --dump 或 --restore")

if __name__ == '__main__':
    main()
