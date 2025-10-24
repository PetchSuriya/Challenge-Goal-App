import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/auth_service.dart';
import '../../../services/image_service.dart';
import '../model/user_model.dart';

/// Profile state that holds all profile-related data and UI states
class ProfileState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool isEditing;
  final bool isSuccess;

  const ProfileState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isEditing = false,
    this.isSuccess = false,
  });

  /// Creates a copy of the current state with optional parameter updates
  ProfileState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? isEditing,
    bool? isSuccess,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isEditing: isEditing ?? this.isEditing,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  /// Check if the profile has valid user data
  bool get hasUser => user != null;

  /// Check if there's an error state
  bool get hasError => error != null;

  @override
  String toString() => 'ProfileState(isLoading: $isLoading, hasUser: $hasUser, error: $error, isEditing: $isEditing, isSuccess: $isSuccess)';
}

/// Controller that manages profile-related business logic and state
class ProfileController extends StateNotifier<ProfileState> {
  final AuthService _authService;

  ProfileController(this._authService) : super(const ProfileState()) {
    _initializeProfile();
  }

  /// Initialize profile by loading user data
  Future<void> _initializeProfile() async {
    await loadProfile();
  }

  /// Load user profile from storage and API
  Future<void> loadProfile() async {
    if (state.isLoading) return; // Prevent multiple concurrent loads

    _setLoadingState();

    try {
      // First, try to get cached user data for immediate UI update
      final cachedUser = await _authService.getUserData();
      if (cachedUser != null) {
        state = state.copyWith(user: cachedUser, isLoading: true);
      }

      // Then fetch fresh data from API
      final result = await _authService.getProfile();
      _handleProfileResult(result);
    } catch (e) {
      _handleError('Failed to load profile: ${e.toString()}');
    }
  }

  /// Update user profile data
  Future<void> updateProfile(UserModel updatedUser) async {
    if (state.isLoading) return; // Prevent multiple concurrent updates

    _setLoadingState();

    try {
      final result = await _authService.updateProfile(updatedUser);
      
      if (result.isSuccess && result.user != null) {
        state = state.copyWith(
          isLoading: false,
          user: result.user,
          isEditing: false,
          isSuccess: true,
          error: null,
        );
      } else {
        _handleError(result.error ?? 'Failed to update profile');
      }
    } catch (e) {
      _handleError('Failed to update profile: ${e.toString()}');
    }
  }

  /// Start editing mode
  void startEditing() {
    if (!state.isLoading) {
      state = state.copyWith(isEditing: true, error: null);
    }
  }

  /// Cancel editing mode and clear any errors
  void cancelEditing() {
    state = state.copyWith(isEditing: false, error: null);
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear success state
  void clearSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  /// Force reload profile data (use after login)
  Future<void> forceReloadProfile() async {
    state = const ProfileState(); // Reset state first
    await loadProfile();
  }

  /// === Image Management Methods ===
  
  /// อัพเดทรูปโปรไฟล์ใหม่จากการเลือกรูปภาพ
  /// 
  /// Parameters:
  /// - imageFile: XFile ที่ได้จาก ImagePicker
  /// 
  /// Process:
  /// 1. เช็คว่ากำลังโหลดอยู่หรือไม่
  /// 2. บันทึกรูปลง local storage ด้วย ImageService
  /// 3. อัพเดท UserModel ด้วย path ใหม่
  /// 4. เซฟข้อมูลผ่าน AuthService
  /// 5. อัพเดท UI state
  Future<void> updateProfileImage(XFile imageFile) async {
    if (state.isLoading || state.user == null) return;

    _setLoadingState();

    try {
      // 1. บันทึกรูปลง local storage
      final String? savedPath = await ImageService.saveProfileImage(
        imageFile: imageFile,
        userId: state.user!.id,
      );

      if (savedPath == null) {
        _handleError('ไม่สามารถบันทึกรูปภาพได้');
        return;
      }

      // 2. อัพเดท user model ด้วย path ใหม่
      final updatedUser = state.user!.copyWith(
        profileImagePath: savedPath,
        updatedAt: DateTime.now(), // อัพเดทเวลาที่แก้ไข
      );

      // 3. บันทึกข้อมูลผ่าน AuthService
      final result = await _authService.updateProfile(updatedUser);
      
      if (result.isSuccess && result.user != null) {
        state = state.copyWith(
          isLoading: false,
          user: result.user,
          isSuccess: true,
          error: null,
        );
      } else {
        _handleError(result.error ?? 'ไม่สามารถอัพเดทรูปโปรไฟล์ได้');
      }
    } catch (e) {
      _handleError('เกิดข้อผิดพลาดในการอัพเดทรูปโปรไฟล์: ${e.toString()}');
    }
  }

  /// ลบรูปโปรไฟล์ (รีเซ็ตเป็นไม่มีรูป)
  /// 
  /// Process:
  /// 1. อัพเดท UserModel โดยเคลียร์ profileImagePath และ profileImageUrl
  /// 2. บันทึกข้อมูลผ่าน AuthService
  /// 3. อัพเดท UI state
  Future<void> removeProfileImage() async {
    if (state.isLoading || state.user == null) return;

    _setLoadingState();

    try {
      // อัพเดท user model โดยเคลียร์รูปโปรไฟล์
      final updatedUser = state.user!.copyWith(
        profileImagePath: null,
        profileImageUrl: null, // เคลียร์ทั้ง local path และ URL
        updatedAt: DateTime.now(),
      );

      // บันทึกข้อมูลผ่าน AuthService
      final result = await _authService.updateProfile(updatedUser);
      
      if (result.isSuccess && result.user != null) {
        state = state.copyWith(
          isLoading: false,
          user: result.user,
          isSuccess: true,
          error: null,
        );
      } else {
        _handleError(result.error ?? 'ไม่สามารถลบรูปโปรไฟล์ได้');
      }
    } catch (e) {
      _handleError('เกิดข้อผิดพลาดในการลบรูปโปรไฟล์: ${e.toString()}');
    }
  }

  /// Logout user and clear all data
  Future<void> logout() async {
    try {
      await _authService.logout();
      state = const ProfileState(); // Reset to initial state
    } catch (e) {
      _handleError('Failed to logout: ${e.toString()}');
    }
  }

  // Private helper methods

  void _setLoadingState() {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
  }

  void _handleProfileResult(ProfileResult result) {
    if (result.isSuccess && result.user != null) {
      state = state.copyWith(
        isLoading: false,
        user: result.user,
        error: null,
      );
    } else {
      _handleError(result.error ?? 'Failed to load profile');
    }
  }

  void _handleError(String errorMessage) {
    state = state.copyWith(
      isLoading: false,
      error: errorMessage,
      isSuccess: false,
    );
  }
}

// Providers

/// Provider for AuthService singleton
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for ProfileController with dependency injection
final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ProfileController(authService);
});

/// Computed provider for checking if user is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  final profileState = ref.watch(profileControllerProvider);
  return profileState.hasUser;
});

/// Computed provider for current user
final currentUserProvider = Provider<UserModel?>((ref) {
  final profileState = ref.watch(profileControllerProvider);
  return profileState.user;
});