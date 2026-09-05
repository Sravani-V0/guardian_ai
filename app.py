from flask import Flask, request, jsonify
from dotenv import load_dotenv
import os
import requests

load_dotenv()

app = Flask(__name__)

FEATHERLESS_API_KEY = os.getenv("FEATHERLESS_API_KEY")
FEATHERLESS_URL = "https://api.featherless.ai/v1/chat/completions"


@app.route("/analyze-risk", methods=["POST"])
def analyze_risk():
    data = request.get_json() or {}

    prompt = f"""
You are the AI safety reasoning component of Guardian AI, a women's safety
application.

Analyze the following situation:

Person: {data.get("person", "Unknown")}
Location: {data.get("location", "Unknown")}
Time: {data.get("time", "Unknown")}
Journey status: {data.get("journey_status", "Unknown")}
Unexpected movement: {data.get("unexpected_movement", False)}
Unexpected stop: {data.get("unexpected_stop", False)}
User response: {data.get("user_response", "No response")}

Assess the situation conservatively.

Return:
Risk: LOW, MEDIUM, or HIGH
Reason: one short sentence
Recommendation: one short sentence

Important:
- No response alone does NOT prove kidnapping.
- Do not invent facts.
- Emergency decisions should also use deterministic application rules.
"""

    if not FEATHERLESS_API_KEY:
        return jsonify({
            "error": "FEATHERLESS_API_KEY is not configured"
        }), 500

    try:
        response = requests.post(
            FEATHERLESS_URL,
            headers={
                "Authorization": f"Bearer {FEATHERLESS_API_KEY}",
                "Content-Type": "application/json",
                "HTTP-Referer": "http://localhost:5000",
                "X-Title": "Guardian AI"
            },
            json={
                "model": "Qwen/Qwen2.5-7B-Instruct",
                "messages": [
                    {
                        "role": "system",
                        "content": "You are a careful AI safety reasoning assistant."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                "max_tokens": 200
            },
            timeout=30
        )

        if response.status_code != 200:
            return jsonify({
                "error": "Featherless API error",
                "status": response.status_code,
                "details": response.text[:500]
            }), 502

        result = response.json()

        ai_message = result["choices"][0]["message"]["content"]

        return jsonify({
            "success": True,
            "ai_analysis": ai_message
        })

    except Exception as e:
        return jsonify({
            "error": "Could not connect to Featherless",
            "details": str(e)
        }), 500


@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "Guardian AI backend is running"
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)