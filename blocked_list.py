import redis


r = redis.Redis(host="localhost", port=6379, decode_responses=True)

value = r.brpop('eric:visited', timeout=300)
print(value)