import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/models/notification.dart';

class NotificationService {
  /// Get all notifications for the current user
  static Future<List<AppNotification>> getNotifications({int? limit = 50}) async {
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/notifications${limit != null ? '?limit=$limit' : ''}');

      final response = await http.get(
        uri,
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => AppNotification.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      throw Exception('Failed to load notifications: $e');
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadCount() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/count'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['count'] as int? ?? 0;
      } else {
        throw Exception('Failed to load notification count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notification count: $e');
      return 0; // Return 0 on error instead of throwing
    }
  }

  /// Mark a notification as read
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/$notificationId/read'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  static Future<int> markAllAsRead() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/read-all'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error marking all as read: $e');
      return 0;
    }
  }

  /// Delete a notification
  static Future<bool> deleteNotification(int notificationId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/$notificationId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all read notifications
  static Future<int> deleteAllRead() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/read'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error deleting read notifications: $e');
      return 0;
    }
  }

  /// Filter notifications by type
  static List<AppNotification> filterByType(List<AppNotification> notifications, String type) {
    return notifications.where((n) => n.type == type).toList();
  }

  /// Group notifications by date
  static Map<String, List<AppNotification>> groupByDate(List<AppNotification> notifications) {
    final grouped = <String, List<AppNotification>>{};
    final now = DateTime.now();

    for (var notification in notifications) {
      final difference = now.difference(notification.timeCreated);
      String key;

      if (difference.inDays == 0) {
        key = 'Today';
      } else if (difference.inDays == 1) {
        key = 'Yesterday';
      } else if (difference.inDays < 7) {
        key = 'This Week';
      } else if (difference.inDays < 30) {
        key = 'This Month';
      } else {
        key = 'Older';
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(notification);
    }

    return grouped;
  }
}
