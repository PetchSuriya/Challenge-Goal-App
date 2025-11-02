import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  ApiConfig._();

  // Detect correct base host for emulator/desktop/web
  static String get baseHost {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
    // iOS simulator, Windows, macOS, Linux desktop
    return 'http://127.0.0.1:3000';
  }

  static String get baseUrl => baseHost; // no '/api' suffix to compose freely

  // REST endpoints
  static String get loginEndpoint => '$baseUrl/api/login';
  static String get logoutEndpoint => '$baseUrl/api/logout';
  static String get meEndpoint => '$baseUrl/api/me';
  static String get registerEndpoint => '$baseUrl/api/register';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
