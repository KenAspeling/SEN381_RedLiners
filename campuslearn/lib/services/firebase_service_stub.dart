// Stub implementation for web platform (no Firebase Messaging support)

class FirebaseService {
  static Future<void> initialize() async {
    print('[FIREBASE] Web platform - push notifications not supported');
    // Firebase Messaging doesn't work on web, so we just skip it
  }

  static Future<void> deleteToken() async {
    // No-op on web
  }
}
