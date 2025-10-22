import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  // Python Flask API endpoint (separate from main backend)
  static const String baseUrl = 'http://localhost:5001';

  /// Send a message to the AI chatbot and get a response
  static Future<ChatResponse> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/message'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('[CHATBOT] Error sending message: $e');
      return ChatResponse(
        text: "I'm having trouble connecting right now. Please try again later or create a support ticket.",
        requiresTutor: true,
        success: false,
      );
    }
  }

  /// Check if the Python API is healthy
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('[CHATBOT] Health check failed: $e');
      return false;
    }
  }
}

class ChatResponse {
  final String text;
  final bool requiresTutor;
  final bool success;

  ChatResponse({
    required this.text,
    required this.requiresTutor,
    required this.success,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      text: json['text'] as String? ?? 'No response',
      requiresTutor: json['requiresTutor'] as bool? ?? false,
      success: json['success'] as bool? ?? false,
    );
  }
}
