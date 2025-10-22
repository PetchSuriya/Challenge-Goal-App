import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class for HomePage
class HomeState {
  final bool isLoading;
  final String? error;
  final int userLevel;
  final String userStatus;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.userLevel = 1,
    this.userStatus = 'Adventurer',
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    int? userLevel,
    String? userStatus,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userLevel: userLevel ?? this.userLevel,
      userStatus: userStatus ?? this.userStatus,
    );
  }
}

/// Controller for HomePage
class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(const HomeState());

  /// Load user data and initialize home page
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Load user data from API or local storage
      // Simulate loading
      await Future.delayed(const Duration(milliseconds: 500));
      
      // For now, use default values
      state = state.copyWith(
        isLoading: false,
        userLevel: 1,
        userStatus: 'Adventurer',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load user data: $e',
      );
    }
  }

  /// Navigate to Goals page
  void navigateToGoals() {
    // TODO: Implement navigation to goals page
  }

  /// Navigate to Friends page
  void navigateToFriends() {
    // TODO: Implement navigation to friends page
  }

  /// Navigate to Costume page
  void navigateToCostume() {
    // TODO: Implement navigation to costume page
  }

  /// Navigate to Premium page
  void navigateToPremium() {
    // TODO: Implement navigation to premium page
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for HomeController
final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController();
});