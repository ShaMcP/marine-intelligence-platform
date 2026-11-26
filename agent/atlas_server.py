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
    "journalist": "Marine science journalist. Lead with shocking headline, explain in 3-4 sentences, plain language, no jargon.",
    "researcher": "Marine biologist. Scientific precision, note sample sizes, acknowledge data gaps, 4-5 sentences.",
    "conservationist": "Marine conservation officer. Focus on protection implications, end with call to action.",
    "public": "Explain to non-scientist. Simple language, wow-facts, under 150 words, no jargon."
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
        model='claude-haiku-4-5-20251001', max_tokens=500,
        system=PERSONAS.get(data.get('persona', 'journalist')),
        messages=[{'role': 'user', 'content': f'ATLAS data:\n{ATLAS_DATA}\n\n{data["question"]}'}]
    )
    return jsonify({'answer': response.content[0].text})

@app.route('/api/health')
def health():
    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    app.run(port=5050)
