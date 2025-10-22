# CampusLearn AI Chatbot Backend

This is the Python Flask backend for the CampusLearn AI chatbot, powered by Google Gemini AI.

## Features

- 🤖 AI-powered responses using Google Gemini 2.0 Flash (Thinking)
- 🎓 Belgium Campus-specific system instructions
- 🔄 CORS enabled for Flutter app integration
- 👨‍🏫 Automatic tutor escalation detection
- ✅ Health check endpoint

## Setup Instructions

### 1. Install Python Dependencies

```bash
cd "CHATBOT TEMP"
pip install -r requirements.txt
```

Or install individually:
```bash
pip install google-genai==0.3.0
pip install flask==2.3.3
pip install flask-cors==4.0.0
pip install python-dotenv==1.0.0
```

### 2. Set Up Environment Variables

Create a `.env` file in this directory with your Gemini API key:

```
GEMINI_API_KEY=your_api_key_here
```

**Note:** The `env.txt` file contains the current API key. For production, move this to a `.env` file and add `.env` to `.gitignore`.

### 3. Run the Server

```bash
python app.py
```

The server will start on `http://localhost:5000`

## API Endpoints

### POST /api/chat/message

Send a message to the AI chatbot.

**Request:**
```json
{
  "message": "How do I upload a document?"
}
```

**Response:**
```json
{
  "text": "You can upload documents when creating a ticket...",
  "requiresTutor": false,
  "success": true
}
```

### GET /api/health

Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "service": "CampusLearn Python API"
}
```

## Integration with Flutter

The Flutter app automatically connects to this backend via the `ChatbotService` class located at:
- `lib/services/chatbot_service.dart`

The chatbot page is at:
- `lib/pages/chatbot_page.dart`

## How It Works

1. User sends a message in the Flutter app
2. Flutter calls `/api/chat/message` with the message
3. Python backend sends the message to Google Gemini AI
4. AI generates a response with the Belgium Campus context
5. Backend checks if tutor escalation is needed
6. Response is sent back to Flutter
7. If tutor is required, Flutter shows a dialog to create a support ticket

## System Instruction

The AI is configured with the following context:

> "You are the CampusLearn Assistant for Belgium Campus students. Help with:
> - Academic topics from uploaded materials
> - Platform navigation guides
> - Connecting to tutors when needed
> - FAQ answers
>
> Be friendly and supportive. If unsure, say 'I'll connect you with a tutor.'"

## Model Configuration

- **Model:** gemini-2.0-flash-thinking-exp (Free tier)
- **Temperature:** 0.2 (More focused responses)
- **Max Tokens:** 800
- **System Instruction:** Belgium Campus-specific context

## Tutor Escalation

The backend automatically detects when the AI suggests connecting with a tutor by checking if the response contains:
- "connect you with a tutor"
- "i'll connect you"

When detected, the Flutter app shows a dialog offering to create a support ticket.

## Development Notes

- The server runs in debug mode by default (`debug=True`)
- CORS is enabled for all origins (restrict in production)
- API key is loaded from environment variables
- Error handling returns user-friendly messages

## Production Deployment

For production:

1. Set `debug=False` in `app.py`
2. Use a proper WSGI server (gunicorn, uwsgi)
3. Restrict CORS to your Flutter app domain
4. Use environment variables for the API key
5. Add rate limiting
6. Add authentication if needed

Example with gunicorn:
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

## Troubleshooting

**Connection Error in Flutter:**
- Make sure the Python server is running on port 5000
- Check that CORS is enabled
- Verify the API key is set correctly

**API Key Error:**
- Ensure `GEMINI_API_KEY` is set in environment or `.env` file
- Check that the API key is valid at https://aistudio.google.com/apikey

**Import Errors:**
- Run `pip install -r requirements.txt`
- Make sure you're using Python 3.8 or higher
