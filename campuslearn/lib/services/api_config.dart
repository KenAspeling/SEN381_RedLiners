import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Production backend URL - Set this to your hosted backend URL
  // Leave as empty string to use localhost for development
  static const String productionUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: '', // Empty = use localhost, or set your Railway URL here
  );

  // Backend API base URL - automatically detects platform
  static String get baseUrl {
    // If production URL is set, use it (for distributed releases)
    if (productionUrl.isNotEmpty) {
      return productionUrl;
    }

    // Development mode - use localhost based on platform
    if (kIsWeb) {
      // Chrome web browser
      return 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      // Android emulator - 10.0.2.2 refers to host machine's localhost
      return 'http://10.0.2.2:5000';
    } else if (Platform.isIOS) {
      // iOS simulator
      return 'http://localhost:5000';
    } else {
      // Desktop platforms (Windows, macOS, Linux)
      return 'http://localhost:5000';
    }
  }
  
  // API endpoints
  static const String postsEndpoint = '/api/posts';
  static const String topicsEndpoint = '/api/posts'; // Backward compatibility
  static const String commentsEndpoint = '/api/posts'; // Backward compatibility
  static const String authEndpoint = '/api/auth';

  // Full API URLs
  static String get postsUrl => '$baseUrl$postsEndpoint';
  static String get topicsUrl => '$baseUrl$topicsEndpoint'; // Backward compatibility
  static String get commentsUrl => '$baseUrl$commentsEndpoint'; // Backward compatibility
  static String get authUrl => '$baseUrl$authEndpoint';
  
  // Request headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> getAuthHeaders(String? token) {
    final headers = Map<String, String>.from(defaultHeaders);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
  
  // Timeout configurations
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
}