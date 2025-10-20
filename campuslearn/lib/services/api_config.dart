class ApiConfig {
  // Backend API base URL
  static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator alias for host machine
  
  // API endpoints
  static const String topicsEndpoint = '/api/topics';
  static const String commentsEndpoint = '/api/comments';
  static const String authEndpoint = '/api/auth';
  
  // Full API URLs
  static String get topicsUrl => '$baseUrl$topicsEndpoint';
  static String get commentsUrl => '$baseUrl$commentsEndpoint';
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