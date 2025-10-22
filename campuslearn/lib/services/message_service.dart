import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/models/message.dart';

class MessageService {
  /// Get all conversations for the current user
  static Future<List<Conversation>> getConversations() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/messages/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Conversation.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting conversations: $e');
      rethrow;
    }
  }

  /// Get all messages with a specific user
  static Future<List<Message>> getMessagesWithUser(int otherUserId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/messages/user/$otherUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting messages: $e');
      rethrow;
    }
  }

  /// Send a message to a user
  static Future<Message> sendMessage({
    required int recipientId,
    required String content,
    int? materialId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final requestBody = {
        'recipientId': recipientId,
        'content': content,
        if (materialId != null) 'materialId': materialId,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return Message.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send message');
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Mark a message as read
  static Future<void> markAsRead(int messageId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/messages/$messageId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to mark message as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking message as read: $e');
      rethrow;
    }
  }

  /// Get unread message count
  static Future<int> getUnreadCount() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/messages/unread/count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] as int;
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting unread count: $e');
      return 0; // Return 0 on error instead of throwing
    }
  }
}
