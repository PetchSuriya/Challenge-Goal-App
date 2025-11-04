import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/friends_service.dart';

/// State class for Friends features
class FriendsState {
  final bool isLoading;
  final String? error;
  final List<User> searchResults;
  final List<User> friends;
  final List<User> pendingRequests;
  final User? selectedFriend;

  const FriendsState({
    this.isLoading = false,
    this.error,
    this.searchResults = const [],
    this.friends = const [],
    this.pendingRequests = const [],
    this.selectedFriend,
  });

  FriendsState copyWith({
    bool? isLoading,
    String? error,
    List<User>? searchResults,
    List<User>? friends,
    List<User>? pendingRequests,
    User? selectedFriend,
  }) {
    return FriendsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchResults: searchResults ?? this.searchResults,
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      selectedFriend: selectedFriend ?? this.selectedFriend,
    );
  }
}

/// Controller for Friends features
class FriendsController extends StateNotifier<FriendsState> {
  FriendsController(this._friendsService) : super(const FriendsState());

  final FriendsService _friendsService;

  /// Load friends list and pending requests
  Future<void> loadFriends() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final friendsData = await _friendsService.getFriends();
      
      state = state.copyWith(
        isLoading: false,
        friends: friendsData.friends,
        pendingRequests: friendsData.pending,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load friends: $e',
      );
    }
  }

  /// Search for users by username
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _friendsService.searchUsers(query.trim());
      
      state = state.copyWith(
        isLoading: false,
        searchResults: results,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to search users: $e',
      );
    }
  }

  /// Send friend request
  Future<bool> sendFriendRequest(int friendId) async {
    try {
      final success = await _friendsService.sendFriendRequest(friendId);
      if (success) {
        // Refresh search results to update status
        if (state.searchResults.isNotEmpty) {
          final query = state.searchResults.first.username; // Get current search term
          await searchUsers(query);
        }
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to send friend request: $e');
      return false;
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(int friendId) async {
    try {
      final success = await _friendsService.acceptFriendRequest(friendId);
      if (success) {
        // Refresh friends list
        await loadFriends();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to accept friend request: $e');
      return false;
    }
  }

  /// Unfriend a user
  Future<bool> unfriend(int friendId) async {
    try {
      final success = await _friendsService.unfriend(friendId);
      if (success) {
        // Refresh friends list
        await loadFriends();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to unfriend: $e');
      return false;
    }
  }

  /// Load friend details by ID
  Future<void> loadFriendDetails(int friendId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final friend = await _friendsService.getUserById(friendId);
      
      state = state.copyWith(
        isLoading: false,
        selectedFriend: friend,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load friend details: $e',
      );
    }
  }

  /// Clear search results
  void clearSearch() {
    state = state.copyWith(searchResults: []);
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for FriendsService
final friendsServiceProvider = Provider<FriendsService>((ref) {
  return FriendsService();
});

/// Provider for FriendsController
final friendsControllerProvider =
    StateNotifierProvider<FriendsController, FriendsState>((ref) {
      final friendsService = ref.read(friendsServiceProvider);
      return FriendsController(friendsService);
    });
