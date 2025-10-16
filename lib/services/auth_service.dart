import 'package:shared_preferences/shared_preferences.dart';
import '../features/profile/model/user_model.dart';
import '../core/constants/app_constants.dart';

/// Result classes for better error handling and type safety

/// Login operation result
class LoginResult {
  final bool isSuccess;
  final UserModel? user;
  final String? error;

  const LoginResult.success(this.user) : isSuccess = true, error = null;
  const LoginResult.failure(this.error) : isSuccess = false, user = null;

  @override
  String toString() => 'LoginResult(isSuccess: $isSuccess, hasUser: ${user != null}, error: $error)';
}

/// Profile operation result
class ProfileResult {
  final bool isSuccess;
  final UserModel? user;
  final String? error;

  const ProfileResult.success(this.user) : isSuccess = true, error = null;
  const ProfileResult.failure(this.error) : isSuccess = false, user = null;

  @override
  String toString() => 'ProfileResult(isSuccess: $isSuccess, hasUser: ${user != null}, error: $error)';
}

/// Reset password operation result
class ResetPasswordResult {
  final bool isSuccess;
  final String? error;

  const ResetPasswordResult.success() : isSuccess = true, error = null;
  const ResetPasswordResult.failure(this.error) : isSuccess = false;

  @override
  String toString() => 'ResetPasswordResult(isSuccess: $isSuccess, error: $error)';
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

  // Storage keys
  static const String _tokenKey = AppConstants.accessTokenKey;
  static const String _userDataKey = AppConstants.userDataKey;

  // Mock credentials for development
  static const List<Map<String, String>> _validCredentials = AppConstants.mockCredentials;

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
  Future<LoginResult> login(String email, String password) async {
    await _ensureInitialized();
    
    try {
      print('AuthService: Attempting login with email: $email');
      
      // Validate input
      final validationError = _validateLoginInput(email, password);
      if (validationError != null) {
        return LoginResult.failure(validationError);
      }

      // Check credentials
      if (!_isValidCredentials(email, password)) {
        return LoginResult.failure(_getInvalidCredentialsMessage());
      }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create user and save session
      final user = _createMockUser(email);
      await _saveUserSession(user);
      
      print('AuthService: Login successful!');
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
      final storedUser = await getUserData();
      if (storedUser != null) {
        return ProfileResult.success(storedUser);
      } else {
        return const ProfileResult.failure('No user data found');
      }
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
      return ResetPasswordResult.failure('Failed to send reset email: ${e.toString()}');
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
    print('Token saved: ${token.substring(0, 20)}...');
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
      await removeAccessToken();
      await removeUserData();
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

  String? _validateLoginInput(String email, String password) {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return AppConstants.emailRequired;
    }
    return null;
  }

  bool _isValidCredentials(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();
    
    return _validCredentials.any((cred) =>
        cred['email']!.toLowerCase() == normalizedEmail &&
        cred['password'] == normalizedPassword);
  }

  String _getInvalidCredentialsMessage() {
    return 'Invalid credentials!\n\nTry one of these:\n'
        '• admin@bento.app / Bento2025!\n'
        '• test@test.com / 123456\n'
        '• admin / admin';
  }

  UserModel _createMockUser(String email) {
    final now = DateTime.now();
    return UserModel(
      id: 'user_${now.millisecondsSinceEpoch}',
      email: email.trim(),
      firstName: 'Admin',
      lastName: 'User',
      phoneNumber: '+66-1234-5678',
      profileImageUrl: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _saveUserSession(UserModel user) async {
    final token = 'bento_token_${DateTime.now().millisecondsSinceEpoch}';
    await saveAccessToken(token);
    await saveUserData(user);
  }
}