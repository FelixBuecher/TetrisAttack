import os
import redis
from flask import Flask, request, jsonify
from flask_cors import CORS

# Faktor 3 (Konfiguration aus Environments lesen)
REDIS_HOST = os.environ.get("REDISHOST", "redis")
REDIS_PORT = int(os.environ.get("REDISPORT", "6379"))
REST_PORT = int(os.environ.get("RESTPORT", "5000"))
TIMEOUT = int(os.environ.get("TIMEOUT", "5"))

app = Flask(__name__)
app.config["JSON_SORT_KEYS"] = False
CORS(app)  # This allows CORS for all domains on all routes

# Redis Connection
rest = redis.StrictRedis(host=REDIS_HOST, port=REDIS_PORT, db=0, socket_timeout=TIMEOUT)
rest.ping()


# To allow K8s run automatic liveness probes for self-healing
@app.route("/healthz", methods=["GET"])
def health():
    rest.ping()
    return "OK"


# curl -X OPTIONS http://localhost:5000/highscore
@app.route("/highscore", methods=["OPTIONS"])
def options_rest():
    return "POST, GET, DELETE, PUT, OPTIONS"


# curl -X POST -d "uid=123" -d "name=player1" -d "score=12" http://localhost:5000/highscore
@app.route("/highscore", methods=["POST", "PUT"])
def post_rest():
    uid = request.values.get("uid", None)
    name = request.values.get("name", None)
    score = request.values.get("score", None)
    if not uid:
        return f"Bad request: invalid uid parameter", 400
    if not name:
        return f"Bad request: Invalid name parameter", 400
    if not score:
        return f"Bad request: Invalid score parameter", 400
    orig = rest.get(uid)
    rest.zadd("scores", {uid: int(score)})
    rest.set(uid, name)
    return orig.decode("utf-8") if orig else ""


# curl http://localhost:5000/highscore                  |   (for top 10 scores)
# curl -d "uid=123" http://localhost:5000/highscore     |   (for specific score)
@app.route("/highscore", methods=["GET"])
def get_rest():
    uid = request.values.get("uid", None)
    if not uid:
        toplist = rest.zrevrange("scores", 0, 9, withscores=True)
        untupled = [e for sub in toplist for e in sub]
        scores = {}
        for i in range(0, len(untupled), 2):
            name = rest.get(untupled[i])
            score = untupled[i + 1]
            scores[i] = {"name": name, "score": score}
        return jsonify({scores[k]["name"].decode("utf-8"): scores[k]["score"] for k in scores})
    name = rest.get(uid)
    if not name:
        return f"{uid} not found", 404
    score = rest.zscore("scores", uid)
    return jsonify({name.decode("utf-8"): str(score.real)})


# curl -X DELETE -d "uid=123" http://localhost:5000/highscore
@app.route("/highscore", methods=["DELETE"])
def delete_rest():
    uid = request.values.get("uid", None)
    orig = rest.get(uid)
    if orig:
        rest.delete(uid)
        rest.zrem("scores", uid)
    return orig.decode("utf-8") if orig else ""


app.run(host="0.0.0.0", port=REST_PORT)
