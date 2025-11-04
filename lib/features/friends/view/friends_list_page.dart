import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controller/friends_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/friends_service.dart';

class FriendsListPage extends ConsumerStatefulWidget {
  const FriendsListPage({super.key});

  @override
  ConsumerState<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends ConsumerState<FriendsListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load friends when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendsControllerProvider.notifier).loadFriends();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Friends',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.homeRoute),
        ),
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search friends by username...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(friendsControllerProvider.notifier).clearSearch();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onChanged: (query) {
                      ref.read(friendsControllerProvider.notifier).searchUsers(query);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: friendsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : friendsState.error != null
                    ? _buildErrorWidget(friendsState.error!)
                    : _buildContent(friendsState),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(FriendsState state) {
    // Show search results if searching
    if (state.searchResults.isNotEmpty) {
      return _buildSearchResults(state.searchResults);
    }

    // Show friends list and pending requests
    return RefreshIndicator(
      onRefresh: () => ref.read(friendsControllerProvider.notifier).loadFriends(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pending Friend Requests
            if (state.pendingRequests.isNotEmpty) ...[
              _buildSectionHeader('Pending Requests', Icons.person_add),
              const SizedBox(height: 12),
              ...state.pendingRequests.map((user) => _buildPendingRequestCard(user)),
              const SizedBox(height: 24),
            ],

            // Friends List
            _buildSectionHeader('My Friends (${state.friends.length})', Icons.people),
            const SizedBox(height: 12),
            if (state.friends.isEmpty)
              _buildEmptyFriendsWidget()
            else
              ...state.friends.map((user) => _buildFriendCard(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<User> searchResults) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final user = searchResults[index];
        return _buildSearchResultCard(user);
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade600, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildFriendCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.green.shade100,
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(
              color: Colors.green.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: user.email != null
            ? Text(
                user.email!,
                style: TextStyle(color: Colors.grey.shade600),
              )
            : null,
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          onSelected: (value) {
            if (value == 'unfriend') {
              _showUnfriendDialog(user);
            } else if (value == 'view') {
              // Navigate to friend's profile
              context.go('/friends/profile/${user.id}');
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 8),
                  Text('View Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'unfriend',
              child: Row(
                children: [
                  Icon(Icons.person_remove, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Unfriend', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to friend's profile page
          context.go('/friends/profile/${user.id}');
        },
      ),
    );
  }

  Widget _buildPendingRequestCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.orange.shade100,
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(
              color: Colors.orange.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: const Text('Wants to be your friend'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Accept button
            ElevatedButton(
              onPressed: () => _acceptFriendRequest(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size(60, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Accept'),
            ),
            const SizedBox(width: 8),
            // Decline button
            OutlinedButton(
              onPressed: () => _declineFriendRequest(user),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                minimumSize: const Size(60, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Decline'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(User user) {
    String? buttonText;
    Color? buttonColor;
    VoidCallback? onPressed;

    switch (user.status) {
      case 'accepted':
        buttonText = 'Friends';
        buttonColor = Colors.green;
        break;
      case 'pending':
        buttonText = 'Pending';
        buttonColor = Colors.orange;
        break;
      case 'requested_by_them':
        buttonText = 'Accept';
        buttonColor = Colors.blue;
        onPressed = () => _acceptFriendRequest(user);
        break;
      default:
        buttonText = 'Add Friend';
        buttonColor = Colors.green;
        onPressed = () => _sendFriendRequest(user);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: user.email != null
            ? Text(
                user.email!,
                style: TextStyle(color: Colors.grey.shade600),
              )
            : null,
        trailing: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(buttonText),
        ),
      ),
    );
  }

  Widget _buildEmptyFriendsWidget() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No friends yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for friends above to get started!',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(friendsControllerProvider.notifier).clearError();
              ref.read(friendsControllerProvider.notifier).loadFriends();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _sendFriendRequest(User user) async {
    final success = await ref
        .read(friendsControllerProvider.notifier)
        .sendFriendRequest(user.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request sent to ${user.username}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _acceptFriendRequest(User user) async {
    final success = await ref
        .read(friendsControllerProvider.notifier)
        .acceptFriendRequest(user.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.username} is now your friend!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _declineFriendRequest(User user) async {
    // For now, declining is the same as unfriending
    final success = await ref
        .read(friendsControllerProvider.notifier)
        .unfriend(user.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request from ${user.username} declined'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showUnfriendDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unfriend'),
        content: Text('Are you sure you want to unfriend ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(friendsControllerProvider.notifier)
                  .unfriend(user.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.username} has been unfriended'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Unfriend'),
          ),
        ],
      ),
    );
  }
}