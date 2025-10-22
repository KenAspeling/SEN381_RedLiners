import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';  // Temporarily disabled for web compatibility
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseService {
  /// Initialize Firebase and request notification permissions
  static Future<void> initialize() async {
    try {
      // Initialize Firebase Core only (FCM disabled for web compatibility)
      await Firebase.initializeApp();
      print('[FIREBASE] Core initialized - FCM disabled for web compatibility');
      print('[FIREBASE] To enable push notifications, uncomment firebase_messaging in pubspec.yaml and test on Android/iOS');

      // TODO: Uncomment when testing on Android/iOS
      // if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      //   _messaging = FirebaseMessaging.instance;
      //   await requestPermission();
      //   await _getFCMToken();
      //   FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      //     _sendTokenToBackend(newToken);
      //   });
      // }

    } catch (e) {
      print('[FIREBASE ERROR] Failed to initialize: $e');
    }
  }

  /// Delete FCM token from backend (call on logout)
  static Future<void> deleteToken() async {
    // No-op when FCM is disabled
    print('[FIREBASE] FCM disabled - skipping token deletion');
  }

  // All Firebase Messaging code commented out for web compatibility
  // Uncomment when testing on Android/iOS with firebase_messaging package enabled
  /*
  static FirebaseMessaging? _messaging;

  static Future<void> requestPermission() async {
    if (_messaging == null) return;
    try {
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('[FIREBASE] User granted notification permission');
      }
    } catch (e) {
      print('[FIREBASE ERROR] Failed to request permission: $e');
    }
  }

  static Future<void> _getFCMToken() async {
    if (_messaging == null) return;
    try {
      final token = await _messaging!.getToken();
      if (token != null) {
        print('[FIREBASE] FCM Token: $token');
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      print('[FIREBASE ERROR] Failed to get FCM token: $e');
    }
  }

  static Future<void> _sendTokenToBackend(String token) async {
    try {
      final authToken = await AuthService.getToken();
      if (authToken == null) return;
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/fcm/token'),
        headers: {
          ...ApiConfig.getAuthHeaders(authToken),
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fcmToken': token,
          'deviceType': 'android',
          'deviceInfo': 'Flutter App',
        }),
      ).timeout(ApiConfig.requestTimeout);
      if (response.statusCode == 200) {
        print('[FIREBASE] Token sent to backend successfully');
      }
    } catch (e) {
      print('[FIREBASE ERROR] Failed to send token to backend: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('[FIREBASE] Background message: ${message.notification?.title}');
  }
  */
}
