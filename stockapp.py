from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

API_KEY = "YOUR_TWELVEDATA_KEY"

@app.route("/price")
def price():
    symbol = request.args.get("symbol")

    url = f"https://api.twelvedata.com/price?symbol={symbol}&apikey={API_KEY}"
    r = requests.get(url).json()

    return jsonify(r)

app.run(port=5000)
