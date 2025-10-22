import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification channels
  static const String _uploadChannelId = 'file_uploads';
  static const String _uploadChannelName = 'File Uploads';
  static const String _downloadChannelId = 'file_downloads';
  static const String _downloadChannelName = 'File Downloads';

  Future<void> initialize() async {
    if (kIsWeb) {
      print('[NOTIFICATIONS] Web platform - notifications not supported');
      return;
    }

    if (_initialized) return;

    try {
      // Android initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions for Android 13+
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _initialized = true;
      print('[NOTIFICATIONS] Initialized successfully');
    } catch (e) {
      print('[NOTIFICATIONS] Initialization error: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('[NOTIFICATIONS] Notification tapped: ${response.payload}');
    // TODO: Handle notification tap - could navigate to file or ticket
  }

  /// Show upload progress notification
  Future<void> showUploadProgress({
    required int id,
    required String fileName,
    required int progress, // 0-100
  }) async {
    if (kIsWeb || !_initialized) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        _uploadChannelId,
        _uploadChannelName,
        channelDescription: 'Shows progress of file uploads',
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: 100,
        progress: progress,
        onlyAlertOnce: true,
        playSound: false,
        icon: '@mipmap/ic_launcher',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id,
        'Uploading file',
        '$fileName • $progress%',
        details,
      );
    } catch (e) {
      print('[NOTIFICATIONS] Error showing upload progress: $e');
    }
  }

  /// Show upload completion notification
  Future<void> showUploadComplete({
    required int id,
    required String fileName,
    bool success = true,
  }) async {
    if (kIsWeb || !_initialized) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        _uploadChannelId,
        _uploadChannelName,
        channelDescription: 'Shows progress of file uploads',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id,
        success ? 'Upload complete' : 'Upload failed',
        fileName,
        details,
      );

      // Auto-dismiss after 3 seconds if successful
      if (success) {
        Future.delayed(const Duration(seconds: 3), () {
          _notifications.cancel(id);
        });
      }
    } catch (e) {
      print('[NOTIFICATIONS] Error showing upload complete: $e');
    }
  }

  /// Show download progress notification
  Future<void> showDownloadProgress({
    required int id,
    required String fileName,
    required int progress, // 0-100
  }) async {
    if (kIsWeb || !_initialized) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        _downloadChannelId,
        _downloadChannelName,
        channelDescription: 'Shows progress of file downloads',
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: 100,
        progress: progress,
        onlyAlertOnce: true,
        playSound: false,
        icon: '@mipmap/ic_launcher',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id,
        'Downloading file',
        '$fileName • $progress%',
        details,
      );
    } catch (e) {
      print('[NOTIFICATIONS] Error showing download progress: $e');
    }
  }

  /// Show download completion notification with "Open" action
  Future<void> showDownloadComplete({
    required int id,
    required String fileName,
    required String filePath,
    bool success = true,
  }) async {
    if (kIsWeb || !_initialized) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        _downloadChannelId,
        _downloadChannelName,
        channelDescription: 'Shows progress of file downloads',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        actions: success
            ? [
                const AndroidNotificationAction(
                  'open',
                  'Open',
                  showsUserInterface: true,
                ),
              ]
            : null,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id,
        success ? 'Download complete' : 'Download failed',
        fileName,
        details,
        payload: filePath,
      );
    } catch (e) {
      print('[NOTIFICATIONS] Error showing download complete: $e');
    }
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    if (kIsWeb || !_initialized) return;
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    await _notifications.cancelAll();
  }
}
