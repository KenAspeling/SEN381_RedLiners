import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/api_config.dart';

class SubscriptionService {
  // Subscribe to a topic or module
  // subscribableType: 1 = Topic, 2 = Module
  static Future<Map<String, dynamic>?> subscribe({
    required int subscribableType,
    required int subscribableId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/subscriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'subscribableType': subscribableType,
          'subscribableId': subscribableId,
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to subscribe: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error subscribing: $e');
      rethrow;
    }
  }

  // Unsubscribe from a topic or module
  // subscribableType: 1 = Topic, 2 = Module
  static Future<bool> unsubscribe({
    required int subscribableType,
    required int subscribableId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/subscriptions/$subscribableType/$subscribableId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        return false; // Not subscribed
      } else {
        throw Exception('Failed to unsubscribe: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error unsubscribing: $e');
      rethrow;
    }
  }

  // Check if user is subscribed to a specific topic or module
  // subscribableType: 1 = Topic, 2 = Module
  static Future<bool> isSubscribed({
    required int subscribableType,
    required int subscribableId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/subscriptions/check/$subscribableType/$subscribableId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isSubscribed'] as bool;
      } else {
        throw Exception('Failed to check subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking subscription: $e');
      return false;
    }
  }

  // Get all subscriptions for the current user
  static Future<List<Map<String, dynamic>>> getUserSubscriptions() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/subscriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting subscriptions: $e');
      return [];
    }
  }

  // Get subscriptions by type (1 = Topic, 2 = Module)
  static Future<List<Map<String, dynamic>>> getUserSubscriptionsByType(int subscribableType) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/subscriptions/type/$subscribableType'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get subscriptions by type: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting subscriptions by type: $e');
      return [];
    }
  }

  // Toggle subscription (subscribe if not subscribed, unsubscribe if subscribed)
  // Pass current state to avoid extra API call
  static Future<bool> toggleSubscription({
    required int subscribableType,
    required int subscribableId,
    required bool currentlySubscribed,
  }) async {
    try {
      if (currentlySubscribed) {
        print('[SUBSCRIPTION] Unsubscribing from $subscribableType:$subscribableId');
        final success = await unsubscribe(
          subscribableType: subscribableType,
          subscribableId: subscribableId,
        );
        print('[SUBSCRIPTION] Unsubscribe result: $success');
        return false; // Now unsubscribed
      } else {
        print('[SUBSCRIPTION] Subscribing to $subscribableType:$subscribableId');
        await subscribe(
          subscribableType: subscribableType,
          subscribableId: subscribableId,
        );
        print('[SUBSCRIPTION] Subscribe completed');
        return true; // Now subscribed
      }
    } catch (e) {
      print('[SUBSCRIPTION ERROR] Error toggling subscription: $e');
      rethrow;
    }
  }
}
