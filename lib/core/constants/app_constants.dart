import 'dart:ui';

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
  static const String registerRoute = '/register';
  static const String profileRoute = '/profile';
  static const String resetPasswordRoute = '/reset-password';
  static const String dashboardRoute = '/dashboard';
  static const String goalRoute = '/goals';
  static const String goalDetailRoute = '/goals/detail';
  static const String friendRoute = '/friends';
  static const String homeRoute = '/home';
  static const String settingsRoute = '/settings';
  static const String friendsRoute = '/friends';

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
  static const String networkError =
      'Network error. Please check your connection.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String loginSuccess = 'Login successful!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String resetPasswordSuccess =
      'Password reset link sent to your email.';
  static const String logoutSuccess = 'Logged out successfully.';
  static const String sessionExpired =
      'Your session has expired. Please login again.';

  // Validation messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least $minPasswordLength characters';
  static const String passwordTooLong =
      'Password must not exceed $maxPasswordLength characters';
  static const String nameRequired = 'Name is required';
  static const String nameTooShort =
      'Name must be at least $minNameLength characters';
  static const String nameTooLong =
      'Name must not exceed $maxNameLength characters';
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
  // Costume feature
  static const String costumeRoute = '/costumes';
  static const String selectedCostumeKey = 'selected_costume';
  // Key to persist owned/unlocked costume filenames
  static const String ownedCostumesKey = 'owned_costumes';
  // Default locked costumes (filenames as present in assets/images)
  static const List<String> defaultLockedCostumes = [
    'Black_cap.png',
    'Blue_cap.png',
    'Yellow_cap.png',
    'Red_hat.png',
    'White_hat.png',
    'Blue_dress.png',
    'Pink_dress.png',
    'Yellow_dress.png',
  ];
  // Per-slot selected costume keys (one item can be worn per slot)
  static const String selectedCostumeHeadKey = 'selected_costume_head';
  static const String selectedCostumeBodyKey = 'selected_costume_body';
  static const String selectedCostumeHandKey = 'selected_costume_hand';
  // Backwards-compatible alias: older code or persisted data may still use
  // `selected_costume_hand`.
  // Avatar/costume sizing to keep placement consistent across screens
  static const double avatarCostumeWidth = 400.0;
  static const double costumeHatWidthFactor =
      0.533; // hat width = avatarWidth * factor
  static const double costumeHatAlignmentY =
      -0.48; // vertical alignment for hat overlay
  // Body and hand sizing/placement (relative to avatar width)
  static const double costumeBodyWidthFactor =
      0.95; // roughly full-body overlay
  static const double costumeBodyAlignmentY = 0.08; // slightly below top center
  // Foot (formerly 'hand') sizing/placement (relative to avatar width)
  static const double costumeHandWidthFactor = 0.28; // small accessory on hand
  static const double costumeHandAlignmentY = 0.45; // lower area
  static const double costumeHandAlignmentX =
      0.4; // positive -> right, negative -> left
  // Per-costume pixel offsets (x, y) applied after alignment. Use small values
  // Per-context offsets: allow different offsets when previewing in the
  // CostumePage vs rendering on the HomePage. Use the preview/home maps
  // below for per-context tuning. The legacy `costumeOffsets` map was
  // removed to avoid duplication; if you need a global map, reintroduce it.
  static const Map<String, Offset> costumeOffsetsPreview = {
    'Black_cap.png': Offset(-15, -60),
    'Blue_cap.png': Offset(-15, -60),
    'Green_hat.png': Offset(-5, -75),
    'Red_hat.png': Offset(-5, -75),
    'White_hat.png': Offset(-5, -75),
    'Yellow_cap.png': Offset(-15, -60),
    'Black_suit.png': Offset(0, 6),
    'Blue_suit.png': Offset(0, 6),
    'Brown_suit.png': Offset(0, 6),
    'Blue_dress.png': Offset(-3, 8),
    'Pink_dress.png': Offset(-7, 8),
    'Yellow_dress.png': Offset(-4, 8),
  };
  static const Map<String, Offset> costumeOffsetsHome = {
    'Black_cap.png': Offset(-40, -16),
    'Blue_cap.png': Offset(-40, -16),
    'Green_hat.png': Offset(-25, -40),
    'Red_hat.png': Offset(-25, -40),
    'White_hat.png': Offset(-25, -40),
    'Yellow_cap.png': Offset(-40, -16),
    'Black_suit.png': Offset(-20, 4),
    'Blue_suit.png': Offset(-20, 4),
    'Brown_suit.png': Offset(-20, 4),
    'Blue_dress.png': Offset(-25, 30),
    'Pink_dress.png': Offset(-31, 40),
    'Yellow_dress.png': Offset(-26, 30),
  };
  // Normalized per-context offsets (fractions of avatar width).
  // These are computed from the pixel maps above using reference avatar width = 400.
  // Using normalized offsets keeps placement proportional on different screen sizes.
  static const Map<String, Offset> costumeOffsetsPreviewNormalized = {
    'Black_cap.png': Offset(-0.05, 0.14),
    'Blue_cap.png': Offset(-0.05, 0.14),
    'Yellow_cap.png': Offset(-0.05, 0.14),
    'Green_hat.png': Offset(-0.0125, 0.1),
    'Red_hat.png': Offset(-0.0125, 0.09),
    'White_hat.png': Offset(-0.0125, 0.09),
    'Black_suit.png': Offset(0.0, -0.01),
    'Blue_suit.png': Offset(-0.005, -0.01),
    'Brown_suit.png': Offset(0.0, -0.01),
    'Blue_dress.png': Offset(-0.01, 0.02),
    'Pink_dress.png': Offset(-0.025, 0.02),
    'Yellow_dress.png': Offset(-0.015, 0.02),
  };
  static const Map<String, Offset> costumeOffsetsHomeNormalized = {
    'Black_cap.png': Offset(-0.05, -0.03),
    'Blue_cap.png': Offset(-0.05, -0.03),
    'Yellow_cap.png': Offset(-0.05, -0.03),
    'Green_hat.png': Offset(-0.015, -0.09),
    'Red_hat.png': Offset(-0.015, -0.1),
    'White_hat.png': Offset(-0.015, -0.1),
    'Black_suit.png': Offset(-0.003, 0.01),
    'Blue_suit.png': Offset(-0.003, 0.01),
    'Brown_suit.png': Offset(-0.003, 0.01),
    'Blue_dress.png': Offset(-0.015, 0.075),
    'Pink_dress.png': Offset(-0.03, 0.1),
    'Yellow_dress.png': Offset(-0.015, 0.075),
  };
  // Normalized lap offset; multiply by avatar width to get pixel shift.
  static const double costumeLapOffsetYNormalized = 0.05; // 20 / 400
  // Per-context scales for preview vs home rendering
  static const Map<String, double> costumeScalesPreview = {
    'Black_cap.png': 0.68,
    'Blue_cap.png': 0.65,
    'Yellow_cap.png': 0.65,
    'Green_hat.png': 0.62,
    'Red_hat.png': 0.62,
    'White_hat.png': 0.62,
    'Black_suit.png': 0.38,
    'Blue_suit.png': 0.37,
    'Brown_suit.png': 0.38,
    'Blue_dress.png': 0.60,
    'Pink_dress.png': 0.60,
    'Yellow_dress.png': 0.60,
  };
  static const Map<String, double> costumeScalesHome = {
    'Black_cap.png': 0.67,
    'Blue_cap.png': 0.65,
    'Yellow_cap.png': 0.65,
    'Green_hat.png': 0.60,
    'Red_hat.png': 0.60,
    'White_hat.png': 0.60,
    'Black_suit.png': 0.38,
    'Blue_suit.png': 0.38,
    'Brown_suit.png': 0.38,
    'Blue_dress.png': 0.60,
    'Pink_dress.png': 0.62,
    'Yellow_dress.png': 0.60,
  };
  // Default vertical lap amount (pixels) to move hats down so they "lap" the avatar's head.
  // Positive values move the hat down (towards the avatar), negative move up.
  // Increased from 12.0 to 20.0 to make hats sit more over the avatar's head.
  static const double costumeLapOffsetY = 20.0;
}
