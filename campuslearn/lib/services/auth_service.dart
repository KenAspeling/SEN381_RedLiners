import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _isTutorKey = 'is_tutor';

  // Save JWT token and user info
  static Future<void> saveAuthData({
    required String token,
    required String userId,
    required String email,
    bool isTutor = false,
  }) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userIdKey, value: userId);
      await _storage.write(key: _userEmailKey, value: email);
      await _storage.write(key: _isTutorKey, value: isTutor.toString());
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }

  // Get stored JWT token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  // Get stored user ID
  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      print('Error reading user ID: $e');
      return null;
    }
  }

  // Get stored user email
  static Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      print('Error reading user email: $e');
      return null;
    }
  }

  // Check if current user is a tutor
  static Future<bool> isTutor() async {
    try {
      final isTutorString = await _storage.read(key: _isTutorKey);
      if (isTutorString == null) {
        // Check the JWT token payload as fallback
        final userData = await getUserDataFromToken();
        return userData?['isTutor'] == true;
      }
      return isTutorString.toLowerCase() == 'true';
    } catch (e) {
      print('Error checking tutor status: $e');
      return false;
    }
  }

  // Check if user is logged in (has valid token)
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      
      // Basic token format validation (JWT has 3 parts separated by dots)
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }

      // Check if token is expired (basic check - you can enhance this)
      if (await isTokenExpired(token)) {
        await logout(); // Clear expired token
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Basic token expiration check
  static Future<bool> isTokenExpired(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode payload (second part)
      final payload = parts[1];
      // Add padding if needed for base64 decoding
      final normalizedPayload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      final payloadMap = json.decode(decoded);

      // Check expiration
      final exp = payloadMap['exp'];
      if (exp != null) {
        final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        return DateTime.now().isAfter(expirationDate);
      }

      return false; // If no expiration, consider it valid
    } catch (e) {
      print('Error checking token expiration: $e');
      return true; // If can't parse, consider expired
    }
  }

  // Get user data from token payload
  static Future<Map<String, dynamic>?> getUserDataFromToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload
      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      return json.decode(decoded);
    } catch (e) {
      print('Error extracting user data from token: $e');
      return null;
    }
  }

  // Clear all stored auth data (logout)
  static Future<void> logout() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userEmailKey);
      await _storage.delete(key: _isTutorKey);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Clear all stored data (for testing or complete reset)
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  // Create a mock JWT token for testing (until you have C# backend)
  static String createMockJwtToken(String userId, String email, {bool isTutor = false}) {
    // This is a mock token for testing - replace with real token from C# backend
    final header = base64Url.encode(utf8.encode(json.encode({
      'typ': 'JWT',
      'alg': 'HS256'
    })));

    final payload = base64Url.encode(utf8.encode(json.encode({
      'userId': userId,
      'email': email,
      'isTutor': isTutor,
      'exp': (DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch / 1000).round(),
      'iat': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    })));

    const signature = 'mock_signature_for_testing';

    return '$header.$payload.$signature';
  }
}