import redis


r = redis.Redis(host="localhost", port=6379, decode_responses=True)

pipe = r.pipeline()
pipe.incr('count', 1)
pipe.execute()
