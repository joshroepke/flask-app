from flask import Flask, request, jsonify
from prometheus_flask_exporter import PrometheusMetrics
from prometheus_client import Counter
import logging
import json
import os

# Setup Flask 
app = Flask(__name__)

# Setup Prometheus Metrics with a custom endpoint
metrics = PrometheusMetrics(app, path='/custom-metrics')

# Setup logging 
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# # Setup counter for requests
REQUEST_COUNT = Counter('request_count_total', 'Total number of requests')

# Set message environment variable
MESSAGE = os.getenv('MESSAGE', "Hello World!")

@app.before_request
def log_request_info():
    # Increment the request count
    REQUEST_COUNT.inc()

    # Log request details
    logger.info({
        "event": "request",
        "method": request.method,
        "url": request.url
    })

@app.after_request
def log_request_info(response):
    # Log response details
    logger.info({
        "event": "response",
        "status_code":response.status_code,
    })
    return response

@app.route('/api/message', methods=['GET'])
def get_message():
    logger.info("Handling /api/message request")
    return jsonify({"message": MESSAGE})
