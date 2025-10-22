import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:campuslearn/services/api_config.dart';
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
  static const String _accessLevelKey = 'access_level';


  // Save JWT token and user info
  static Future<void> saveAuthData({
    required String token,
    required String userId,
    required String email,
    int? accessLevel,
  }) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userIdKey, value: userId);
      await _storage.write(key: _userEmailKey, value: email);
      await _storage.write(key: _accessLevelKey, value: accessLevel?.toString() ?? '0');
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

  // Get stored access level
  static Future<int> getAccessLevel() async {
    try {
      final accessLevelString = await _storage.read(key: _accessLevelKey);
      if (accessLevelString == null) {
        // Check the JWT token payload as fallback
        final userData = await getUserDataFromToken();
        final accessLevel = userData?['AccessLevel'];
        if (accessLevel != null) {
          return int.tryParse(accessLevel.toString()) ?? 0;
        }
        return 0; // Default to Student
      }
      return int.tryParse(accessLevelString) ?? 0;
    } catch (e) {
      print('Error reading access level: $e');
      return 0;
    }
  }

  // Check if current user is a tutor or admin (access level >= 2)
  static Future<bool> isTutor() async {
    try {
      final accessLevel = await getAccessLevel();
      return accessLevel >= 2;
    } catch (e) {
      print('Error checking tutor status: $e');
      return false;
    }
  }

  // Check if current user is an admin (access level == 3)
  static Future<bool> isAdmin() async {
    try {
      final accessLevel = await getAccessLevel();
      return accessLevel == 3;
    } catch (e) {
      print('Error checking admin status: $e');
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
      await _storage.delete(key: _accessLevelKey);
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

  // Get user data by ID
  static Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting user by ID: $e');
      rethrow;
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>?> updateProfile({
    String? name,
    String? surname,
    String? phoneNumber,
    String? degree,
    int? yearOfStudy,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final requestBody = <String, dynamic>{};
      if (name != null) requestBody['name'] = name;
      if (surname != null) requestBody['surname'] = surname;
      if (phoneNumber != null) requestBody['phoneNumber'] = phoneNumber;
      if (degree != null) requestBody['degree'] = degree;
      if (yearOfStudy != null) requestBody['yearOfStudy'] = yearOfStudy;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Request password reset code
  static Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to request password reset: ${response.statusCode}');
      }
    } catch (e) {
      print('Error requesting password reset: $e');
      rethrow;
    }
  }

  // Verify reset code
  static Future<bool> verifyResetCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'code': code,
        }),
      ).timeout(ApiConfig.requestTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying reset code: $e');
      return false;
    }
  }

  // Reset password with code
  static Future<bool> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to reset password: ${response.body}');
      }
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // Create a mock JWT token for testing (until you have C# backend)
  static String createMockJwtToken(String userId, String email, {int accessLevel = 0}) {
    // This is a mock token for testing - replace with real token from C# backend
    final header = base64Url.encode(utf8.encode(json.encode({
      'typ': 'JWT',
      'alg': 'HS256'
    })));

    final payload = base64Url.encode(utf8.encode(json.encode({
      'userId': userId,
      'email': email,
      'AccessLevel': accessLevel,
      'exp': (DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch / 1000).round(),
      'iat': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    })));

    const signature = 'mock_signature_for_testing';

    return '$header.$payload.$signature';
  }
}