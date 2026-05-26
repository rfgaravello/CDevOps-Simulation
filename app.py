from flask import Flask, jsonify, request
import os

app = Flask(__name__)

@app.route('/api/v1/telemetry', methods=['POST'])
def receive_telemetry():
    data = request.get_json()
    # Simula validação rigorosa de dados de saúde
    if not data or 'device_id' not in data or 'heart_rate' not in data:
        return jsonify({"status": "error", "message": "Invalid telemetry payload"}), 400
    
    return jsonify({
        "status": "processed",
        "device_id": data['device_id'],
        "environment": os.getenv("APP_ENV", "development")
    }), 200

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "UP", "component": "Telemetry-Receiver"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)  # nosec B104