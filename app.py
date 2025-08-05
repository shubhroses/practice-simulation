import time
import logging
from datetime import datetime
from flask import Flask, jsonify

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

startup_time = time.time()

@app.route("/health")
def health_check():
    """Health check endpoint for kubernetes probes."""
    uptime = time.time() - startup_time

    health_data = {
        "status": "Healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "uptime": round(uptime, 2),
        "service": "flask-demo",
        "version": "1.0.0"
    }
    logger.info(f"Heath check endpoint reached at: {uptime:.2f}")
    return jsonify(health_data)

@app.route("/ready")
def readiness_check():
    """Readiness check point for kubernets probes."""
    if time.time() - startup_time > 5:
        logger.info("Readiness check: Ready")
        return jsonify({ "status": "ready" }), 200
    else:
        logger.info("Readiness check: Not ready")
        return jsonify({ "status": "not ready" }), 503      

@app.route("/")
def hello():
    logger.info("Main endpoint is kicked off.")
    return "Hello from Flask in k8s inside of Vagrant!"

if __name__ == "__main__":
    logger.info("Flask application is starting...")
    app.run(host="0.0.0.0", port=5005)