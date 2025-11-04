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
  // Avatar/costume sizing to keep placement consistent across screens
  static const double avatarCostumeWidth = 300.0;
  static const double costumeHatWidthFactor =
      0.533; // hat width = avatarWidth * factor
  static const double costumeHatAlignmentY =
      -0.48; // vertical alignment for hat overlay
  // Per-costume pixel offsets (x, y) applied after alignment. Use small values
  // to nudge hats into place. We provide two separate maps so Home and the
  // Costume preview page can have independent fine-tuning.
  static const Map<String, Offset> costumeOffsetsHome = {
    'Green_hat.png': const Offset(0, -22),
    'Red_hat.png': const Offset(0, -22),
    'White_hat.png': const Offset(0, -22),
    // Tuned suit offsets for Home page (dx, dy). These nudges were
    // adjusted so suits sit correctly on the avatar when rendered in the
    // dashboard. Values are in pixels and will be scaled by
    // `costumeHatScale` / `costumeSuitScale` at render time.
    'Black_suit.png': const Offset(0, 50),
    'Blue_suit.png': const Offset(0, 50),
    'Brown_suit.png': const Offset(0, 50),
    // Shoes (bottom-of-avatar accessories)
    'Blue_shoes.png': const Offset(0, 33),
    'Brown_shoes.png': const Offset(0, 33),
    'Grey_shoes.png': const Offset(0, 33),
  };

  static const Map<String, Offset> costumeOffsetsCostume = {
    // costume page preview might prefer a different lap/placement
    'Green_hat.png': const Offset(0, -4),
    'Red_hat.png': const Offset(0, -4),
    'White_hat.png': const Offset(0, -4),
    // Slightly different (less aggressive) offsets for the preview so
    // the suit appears natural within the Costume page UI.
    'Black_suit.png': const Offset(0, 90),
    'Blue_suit.png': const Offset(0, 90),
    'Brown_suit.png': const Offset(0, 90),
    // Preview offsets for shoes (milder values so preview fits the UI)
    'Blue_shoes.png': const Offset(0, -20),
    'Brown_shoes.png': const Offset(0, -22),
    'Grey_shoes.png': const Offset(0, -20),
  };

  // Backwards-compatible alias (defaults to Home offsets)
  static const Map<String, Offset> costumeOffsets = costumeOffsetsHome;
  // Compatibility map: map older/stored costume filenames to the current
  // asset filenames in assets/images/. This helps when files were renamed or
  // moved but the user's saved preference still uses the old name.
  static const Map<String, String> costumeNameMap = {
    'Green_Cap.png': 'Green_hat.png',
    'Red_Hat.png': 'Red_hat.png',
    'White_Hat.png': 'White_hat.png',
  };
  // Default vertical lap amount (pixels) to move hats down so they "lap" the avatar's head.
  // Positive values move the hat down (towards the avatar), negative move up.
  // Increased from 12.0 to 20.0 to make hats sit more over the avatar's head.
  static const double costumeLapOffsetY = -2.0;
  // Default scales used when you want to adjust costume sizes purely in code
  // (no UI control). These allow independent scaling of hats vs suits.
  // - `costumeHatScale`: scale applied to hat assets and hat-related offsets.
  // - `costumeSuitScale`: scale applied to suit assets and suit-related offsets.
  // Assumption: keep previous default for hats (0.75) and use 0.90 for suits
  // so full-body assets sit proportionally on the avatar. These values can
  // be tuned later if you prefer different sizing.
  static const double costumeHatScale = 0.75;
  // Scale for shoe assets
  static const double costumeShoeScale = 2.0;
  static const double costumeSuitScale = 0.4;
  // Shoe-specific sizing and alignment (shoes render near the avatar bottom)
  static const double costumeShoeWidthFactor = 0.32;
  static const double costumeShoeAlignmentY = 0.86;
  // Suit-specific sizing and alignment. Suits are full-body assets and
  // require different width and vertical alignment compared to hats.
  static const double costumeSuitWidthFactor =
      1.0; // suit width = avatarWidth * factor
  static const double costumeSuitAlignmentY =
      0.0; // suit alignment (center-ish)
}
