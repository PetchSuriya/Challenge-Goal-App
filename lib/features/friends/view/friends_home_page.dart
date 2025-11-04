import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controller/friends_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/friends_service.dart';

class FriendsHomePage extends ConsumerStatefulWidget {
  final int friendId;

  const FriendsHomePage({
    super.key,
    required this.friendId,
  });

  @override
  ConsumerState<FriendsHomePage> createState() => _FriendsHomePageState();
}

class _FriendsHomePageState extends ConsumerState<FriendsHomePage> {
  @override
  void initState() {
    super.initState();
    // Load friend's data when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(friendsControllerProvider.notifier)
          .loadFriendDetails(widget.friendId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendsControllerProvider);

    if (friendsState.isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (friendsState.error != null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load friend details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  friendsState.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppConstants.homeRoute),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final friend = friendsState.selectedFriend;
    if (friend == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Friend not found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppConstants.homeRoute),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context, friend),

            // Main Content Area
            Expanded(
              child: Stack(
                children: [
                  // Friend's Avatar (Center)
                  Positioned(
                    top: 80, // Position below top bar
                    left: 0,
                    right: 0,
                    child: Center(child: _buildFriendAvatar(friend)),
                  ),

                  // Mutual Goal Button (Bottom)
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Center(child: _buildMutualGoalButton(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, User friend) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Left side: Circular avatar + friend's name
          Expanded(
            child: Row(
              children: [
                // Circular avatar icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.green.shade300, Colors.green.shade500],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      friend.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Friend's name
                Expanded(
                  child: Text(
                    friend.username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Right side: Close (X) button
          GestureDetector(
            onTap: () => context.go(AppConstants.homeRoute),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.close, color: Colors.grey.shade600, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendAvatar(User friend) {
    // Use the same transparent PNG approach as the home page avatar
    return Image.asset(
      'assets/images/FfriendsAvatar.png',
      width: 400,
      height: 400,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackFriendAvatar(friend);
      },
    );
  }

  Widget _buildFallbackFriendAvatar(User friend) {
    // Simple fallback avatar without background, matching home page style
    return SizedBox(
      width: 400,
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade200, Colors.green.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 100,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            friend.username,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMutualGoalButton(BuildContext context) {
    return Container(
      width: 220,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade500, Colors.green.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Navigate to mutual goals page
          _showComingSoonDialog(context, 'Mutual Goals');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Mutual Goal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.construction, color: Colors.orange.shade600),
            const SizedBox(width: 12),
            const Text('Coming Soon!'),
          ],
        ),
        content: Text(
          '$feature feature is under development and will be available in the next update.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.green.shade600),
            child: const Text(
              'Got it!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
