import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class for Friends features
class FriendsState {
  final bool isLoading;
  final String? error;
  final String friendName;
  final String friendAvatarUrl;

  const FriendsState({
    this.isLoading = false,
    this.error,
    this.friendName = 'Friend',
    this.friendAvatarUrl = '',
  });

  FriendsState copyWith({
    bool? isLoading,
    String? error,
    String? friendName,
    String? friendAvatarUrl,
  }) {
    return FriendsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      friendName: friendName ?? this.friendName,
      friendAvatarUrl: friendAvatarUrl ?? this.friendAvatarUrl,
    );
  }
}

/// Controller for Friends features
class FriendsController extends StateNotifier<FriendsState> {
  FriendsController() : super(const FriendsState());

  /// Initialize friend's data
  Future<void> initializeFriend({
    required String friendName,
    String? friendAvatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Load friend data from API or local storage
      // Simulate loading
      await Future.delayed(const Duration(milliseconds: 300));
      
      state = state.copyWith(
        isLoading: false,
        friendName: friendName,
        friendAvatarUrl: friendAvatarUrl ?? '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load friend data: $e',
      );
    }
  }

  /// Navigate to Mutual Goals
  void navigateToMutualGoals() {
    // TODO: Implement navigation to mutual goals page
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for FriendsController
final friendsControllerProvider = StateNotifierProvider<FriendsController, FriendsState>((ref) {
  return FriendsController();
});