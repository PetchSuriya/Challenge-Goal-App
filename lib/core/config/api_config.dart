class ApiConfig {
  static const String baseUrl = 'https://your-api-backend.com/api';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String profileEndpoint = '$baseUrl/user/profile';
  static const String updateProfileEndpoint = '$baseUrl/user/profile';
  static const String resetPasswordEndpoint = '$baseUrl/auth/reset-password';
  
  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}