// Stub for notification manager - no notifications on unsupported platforms

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  Future<void> initialize() async {
    print('[NOTIFICATIONS] Stub - notifications not available on this platform');
  }

  Future<void> showUploadProgress({
    required int id,
    required String fileName,
    required int progress,
  }) async {}

  Future<void> showUploadComplete({
    required int id,
    required String fileName,
    bool success = true,
  }) async {}

  Future<void> showDownloadProgress({
    required int id,
    required String fileName,
    required int progress,
  }) async {}

  Future<void> showDownloadComplete({
    required int id,
    required String fileName,
    required String filePath,
    bool success = true,
  }) async {}

  Future<void> cancel(int id) async {}

  Future<void> cancelAll() async {}
}
