/// Application-wide constants and configuration values
/// 
/// This class centralizes all constant values used throughout the application
/// for better maintainability and consistency.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  
  // Route names
  static const String loginRoute = '/login';
  static const String profileRoute = '/profile';
  static const String resetPasswordRoute = '/reset-password';
  static const String dashboardRoute = '/dashboard';
  static const String goalRoute = '/goals';
  static const String homeRoute = '/home';
  static const String settingsRoute = '/settings';
  
  // Validation constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[\d\s\-\(\)]+$';
  
  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 2.0;
  static const int defaultAnimationDuration = 300; // milliseconds
  
  // Network timeouts
  static const int connectTimeoutMs = 30000; // 30 seconds
  static const int receiveTimeoutMs = 30000; // 30 seconds
  
  // Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String loginSuccess = 'Login successful!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String resetPasswordSuccess = 'Password reset link sent to your email.';
  static const String logoutSuccess = 'Logged out successfully.';
  static const String sessionExpired = 'Your session has expired. Please login again.';
  
  // Validation messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least $minPasswordLength characters';
  static const String passwordTooLong = 'Password must not exceed $maxPasswordLength characters';
  static const String nameRequired = 'Name is required';
  static const String nameTooShort = 'Name must be at least $minNameLength characters';
  static const String nameTooLong = 'Name must not exceed $maxNameLength characters';
  static const String phoneInvalid = 'Please enter a valid phone number';
  
  // Mock data for development
  static const List<Map<String, String>> mockCredentials = [
    {'email': 'admin@bento.app', 'password': 'Bento2025!'},
    {'email': 'test@test.com', 'password': '123456'},
    {'email': 'user@example.com', 'password': 'password'},
    {'email': 'admin', 'password': 'admin'},
  ];
  
  // Feature flags
  static const bool enableDebugLogging = true;
  static const bool enableMockData = true;
  static const bool enableBiometricAuth = false;
  
  // App metadata
  static const String appName = 'Bento';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@bento.app';
}