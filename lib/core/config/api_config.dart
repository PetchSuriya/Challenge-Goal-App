// Centralized API configuration for the app

class ApiConfig {
  ApiConfig._();

  // Deployed backend URL (override with --dart-define=API_BASE_URL=... if needed) 
  static const String _defaultBaseUrl = 'https://challenge-goal-app.onrender.com';
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl);

  // REST endpoints
  static String get loginEndpoint => '$baseUrl/api/login';
  static String get logoutEndpoint => '$baseUrl/api/logout';
  static String get meEndpoint => '$baseUrl/api/me';
  static String get registerEndpoint => '$baseUrl/api/register';
  // Goals
  static String goalsEndpoint() => '$baseUrl/api/goals';
  static String goalLogsEndpoint(int goalId) => '$baseUrl/api/goals/$goalId/logs';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
