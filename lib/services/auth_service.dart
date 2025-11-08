import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/profile/model/user_model.dart';
import '../core/constants/app_constants.dart';
import '../core/config/api_config.dart';
import 'api_client.dart';
import 'image_service.dart';

/// Result classes for better error handling and type safety

/// Login operation result
class LoginResult {
  final bool isSuccess;
  final UserModel? user;
  final String? error;

  const LoginResult.success(this.user) : isSuccess = true, error = null;
  const LoginResult.failure(this.error) : isSuccess = false, user = null;

  @override
  String toString() =>
      'LoginResult(isSuccess: $isSuccess, hasUser: ${user != null}, error: $error)';
}

/// Profile operation result
class ProfileResult {
  final bool isSuccess;
  final UserModel? user;
  final String? error;

  const ProfileResult.success(this.user) : isSuccess = true, error = null;
  const ProfileResult.failure(this.error) : isSuccess = false, user = null;

  @override
  String toString() =>
      'ProfileResult(isSuccess: $isSuccess, hasUser: ${user != null}, error: $error)';
}

/// Reset password operation result
class ResetPasswordResult {
  final bool isSuccess;
  final String? error;

  const ResetPasswordResult.success() : isSuccess = true, error = null;
  const ResetPasswordResult.failure(this.error) : isSuccess = false;

  @override
  String toString() =>
      'ResetPasswordResult(isSuccess: $isSuccess, error: $error)';
}

/// Authentication service that handles all auth-related operations
///
/// This service provides login, profile management, and token handling
/// with proper error handling and mock data for development.
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  final Dio _http = ApiClient().dio;

  // Storage keys
  static const String _tokenKey = AppConstants.accessTokenKey;
  static const String _userDataKey = AppConstants.userDataKey;

  // Mock credentials for development
  // Mock credentials for development
  // static const List<Map<String, String>> _validCredentials =
  //     AppConstants.mockCredentials;

  /// Initialize the service (call this at app startup)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      print('AuthService initialized successfully');
    } catch (e) {
      print('AuthService initialization failed: $e');
      rethrow;
    }
  }

  /// Authenticate user with email and password
  Future<LoginResult> login(String identifier, String password) async {
    await _ensureInitialized();

    try {
      print('AuthService: Attempting login with: $identifier');

      // Validate input
      final validationError = _validateLoginInput(identifier, password);
      if (validationError != null) {
        return LoginResult.failure(validationError);
      }




      // Server expects { username, password }
      final body = {
        'username': identifier.trim(),
        'password': password,
      };

      final res = await _http.post(ApiConfig.loginEndpoint, data: body);
      if (res.statusCode != 200) {
        final msg = _extractError(res) ?? 'Login failed (code ${res.statusCode})';
        return LoginResult.failure(msg);
      }

      // Fetch current user using session cookie stored by CookieManager
      final meRes = await _http.get(ApiConfig.meEndpoint);
      if (meRes.statusCode != 200 || meRes.data == null) {
        final msg = _extractError(meRes) ?? 'Failed to load profile';
        return LoginResult.failure(msg);
      }
      var user = _mapServerUserToModel(meRes.data);
      // Merge local persisted profile image (if any) so it survives logout/login
      final latestLocal = await ImageService.findLatestProfileImage(user.id);
      if (latestLocal != null && latestLocal.isNotEmpty) {
        user = user.copyWith(profileImagePath: latestLocal);
      }
      await _saveUserSession(user);
      return LoginResult.success(user);
    } catch (e) {
      print('AuthService: Login error - $e');
      return LoginResult.failure('Login failed: ${e.toString()}');
    }
  }

  /// Get user profile data
  Future<ProfileResult> getProfile() async {
    await _ensureInitialized();

    try {
      // Try fresh from server using session cookie
      final res = await _http.get(ApiConfig.meEndpoint);
      if (res.statusCode == 200 && res.data != null) {
        var user = _mapServerUserToModel(res.data);
        // Hydrate with latest local profile image if present
        final latestLocal = await ImageService.findLatestProfileImage(user.id);
        if (latestLocal != null && latestLocal.isNotEmpty) {
          user = user.copyWith(profileImagePath: latestLocal);
        }
        await saveUserData(user);
        return ProfileResult.success(user);
      }
      // Fallback to cached
      final storedUser = await getUserData();
      if (storedUser != null) return ProfileResult.success(storedUser);
      return const ProfileResult.failure('No user data found');
    } catch (e) {
      return ProfileResult.failure('Failed to load profile: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<ProfileResult> updateProfile(UserModel user) async {
    await _ensureInitialized();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Update timestamps
      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      await saveUserData(updatedUser);
      return ProfileResult.success(updatedUser);
    } catch (e) {
      return ProfileResult.failure('Failed to update profile: ${e.toString()}');
    }
  }

  /// Send password reset email
  Future<ResetPasswordResult> resetPassword(String email) async {
    await _ensureInitialized();

    try {
      if (email.trim().isEmpty) {
        return const ResetPasswordResult.failure('Email is required');
      }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      return const ResetPasswordResult.success();
    } catch (e) {
      return ResetPasswordResult.failure(
        'Failed to send reset email: ${e.toString()}',
      );
    }
  }

  // Token management

  /// Get stored access token
  Future<String?> getAccessToken() async {
    await _ensureInitialized();
    return _prefs?.getString(_tokenKey);
  }

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _ensureInitialized();
    await _prefs?.setString(_tokenKey, token);
    // Avoid RangeError if token shorter than preview length
    final previewLen = token.length < 8 ? token.length : 8;
    final preview = token.substring(0, previewLen);
    print('Token saved (${token.length} chars): $preview...');
  }

  /// Remove access token
  Future<void> removeAccessToken() async {
    await _ensureInitialized();
    await _prefs?.remove(_tokenKey);
  }

  // User data management

  /// Get stored user data
  Future<UserModel?> getUserData() async {
    await _ensureInitialized();

    try {
      final userDataString = _prefs?.getString(_userDataKey);
      if (userDataString != null && userDataString.isNotEmpty) {
        return UserModel.fromJsonString(userDataString);
      }
    } catch (e) {
      print('Error reading user data: $e');
    }
    return null;
  }

  /// Save user data
  Future<void> saveUserData(UserModel user) async {
    await _ensureInitialized();
    await _prefs?.setString(_userDataKey, user.toJsonString());
    print('User data saved: ${user.email}');
  }

  /// Remove user data
  Future<void> removeUserData() async {
    await _ensureInitialized();
    await _prefs?.remove(_userDataKey);
  }

  // Authentication status

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    await _ensureInitialized();
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout user and clear all data
  Future<void> logout() async {
    await _ensureInitialized();

    try {
      // Best-effort server logout
      try { await _http.post(ApiConfig.logoutEndpoint); } catch (_) {}
      await removeAccessToken();
      await removeUserData();
      await ApiClient().clearCookies();
      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }

  // Private helper methods

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  String? _validateLoginInput(String identifier, String password) {
    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      return AppConstants.emailRequired;
    }
    return null;
  }

  // Map server user to app model
  UserModel _mapServerUserToModel(dynamic data) {
    final created = data['created_at']?.toString();
    final createdAt = DateTime.tryParse(created ?? '') ?? DateTime.now();
    return UserModel(
      id: (data['id']?.toString() ?? ''),
      email: (data['email']?.toString() ?? ''),
      firstName: (data['username']?.toString() ?? ''),
      lastName: '',
      phoneNumber: null,
      profileImageUrl: data['profile_picture']?.toString(),
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  String? _extractError(Response res) {
    try {
      final d = res.data;
      if (d is Map && d['error'] is String) return d['error'] as String;
    } catch (_) {}
    return null;
  }

  Future<void> _saveUserSession(UserModel user) async {
    // We store a marker token so existing app logic works; session cookie is in CookieJar
    await saveAccessToken('session_cookie');
    await saveUserData(user);
  }
}
