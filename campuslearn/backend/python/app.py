from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from google import genai
from google.genai import types

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

class CampusLearnChatService:
    def __init__(self):
        self.client = genai.Client(
            api_key=os.environ.get("GEMINI_API_KEY"),
        )
        self.model = "gemini-2.0-flash-thinking-exp"  # Using free tier model
        self.system_instruction = """You are the CampusLearn Assistant for Belgium Campus students. Help with:
- Academic topics from uploaded materials
- Platform navigation guides
- Connecting to tutors when needed
- FAQ answers

Be friendly and supportive. If unsure, say "I'll connect you with a tutor."
"""

    def generate_response(self, message, history=None):
        try:
            contents = [
                types.Content(
                    role="user",
                    parts=[types.Part.from_text(text=message)],
                ),
            ]
            
            generate_content_config = types.GenerateContentConfig(
                temperature=0.2,
                max_output_tokens=800,
                system_instruction=[types.Part.from_text(text=self.system_instruction)],
            )

            response = self.client.models.generate_content(
                model=self.model,
                contents=contents,
                config=generate_content_config,
            )
            
            return {
                'text': response.text,
                'requiresTutor': self._check_tutor_required(response.text),
                'success': True
            }
            
        except Exception as e:
            return {
                'text': f"I'm experiencing technical difficulties. Please try again.",
                'requiresTutor': True,
                'success': False
            }
    
    def _check_tutor_required(self, response):
        response_lower = response.lower()
        return "connect you with a tutor" in response_lower or "i'll connect you" in response_lower

chat_service = CampusLearnChatService()

@app.route('/api/chat/message', methods=['POST'])
def chat_message():
    data = request.get_json()
    message = data.get('message', '')
    
    if not message:
        return jsonify({'success': False, 'error': 'Message is required'})
    
    result = chat_service.generate_response(message)
    return jsonify(result)

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'service': 'CampusLearn Python API'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)