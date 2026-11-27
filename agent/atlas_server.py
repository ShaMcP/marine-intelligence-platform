from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import anthropic
import os

app = Flask(__name__)
CORS(app)

ATLAS_DATA = """
Green Turtle / El Nino / Chagos Archipelago / 28.21C / 2284 records
Green Turtle / El Nino / Gulf of Aden / 27.01C / 1195 records
Green Turtle / La Nina / Chagos Archipelago / 27.80C / 2890 records
Green Turtle / La Nina / Gulf of Aden / 26.42C / 1576 records
Green Turtle / Neutral / Chagos Archipelago / 28.00C / 3641 records
Whale Shark / El Nino / Ningaloo Reef / 23.95C / 489 records
Whale Shark / La Nina / Ningaloo Reef / 23.37C / 621 records
Reef Manta Ray / El Nino / Raja Ampat / 28.95C / 312 records
Reef Manta Ray / La Nina / Raja Ampat / 29.53C / 287 records
Sperm Whale / El Nino / North Atlantic / 21.45C / 1834 records
Sperm Whale / La Nina / North Atlantic / 20.98C / 2156 records
Total: 69776 observations. Green turtles only 0.41C thermal range. Whale sharks decrease at El Nino.
"""

PERSONAS = {
    "journalist": "You are a marine science journalist with a nose for a story. Write like you are telling a friend something that blew your mind — lead with the most striking fact, keep it punchy and conversational, 3-4 sentences. No asterisks, no bullet points, no headers, no markdown. Plain sentences only.",
    "researcher": "You are a marine biologist who loves talking about your work. Be precise and mention sample sizes or data gaps where relevant, but write like you are explaining it over coffee — engaged, curious, 4-5 sentences. No asterisks, no bullet points, no headers, no markdown. Plain sentences only.",
    "conservationist": "You are a passionate marine conservation officer. Write with warmth and urgency — connect the data to what it means for the ocean and end with something the reader can care about or act on. No asterisks, no bullet points, no headers, no markdown. Plain sentences only.",
    "public": "You are a friendly ocean enthusiast talking to someone who has never studied science. Use simple words, share the wow-factor, keep it under 150 words. No asterisks, no bullet points, no headers, no markdown. Plain sentences only."
}

@app.route('/')
def index():
    return send_from_directory('.', 'atlas-ui.html')

@app.route('/api/ask', methods=['POST'])
def ask():
    data = request.json
    api_key = os.environ.get('ANTHROPIC_API_KEY')
    client = anthropic.Anthropic(api_key=api_key)
    response = client.messages.create(
        model='claude-haiku-4-5-20251001',
        max_tokens=500,
        system=PERSONAS.get(data.get('persona', 'journalist')),
        messages=[{'role': 'user', 'content': f'ATLAS data:\n{ATLAS_DATA}\n\n{data["question"]}'}]
    )
    return jsonify({'answer': response.content[0].text})

@app.route('/api/health')
def health():
    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    app.run(port=5050)
