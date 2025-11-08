import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../goal/view/friend_goals_page.dart';
import '../controller/friends_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/friends_service.dart';
import 'dart:math' as math;
// (no extra services needed)

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
      // Defensive: ensure friendId > 0 before loading
      if (widget.friendId > 0) {
        ref
            .read(friendsControllerProvider.notifier)
            .loadFriendDetails(widget.friendId);
      } else {
        ref.read(friendsControllerProvider.notifier).clearError();
      }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.homeRoute),
        ),
        title: Row(
          children: [
            _GradientCircleInitial(friend.username),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                friend.username,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _MutualGoalsActionButton(
              onPressed: () {
                final f = ref.read(friendsControllerProvider).selectedFriend;
                if (f != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FriendGoalsPage(friend: f),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minSectionHeight = (constraints.maxHeight - 32).clamp(300.0, double.infinity);
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minSectionHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Friend Overview section (full-width feel)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Large friend illustration
                        Center(
                          child: SizedBox(
                            height: 340,
                            child: _FriendAvatarView(friend: friend),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Friend Overview',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Track progress & start a mutual goal together.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 28),
                        // Full-width gradient button near bottom of section
                        SizedBox(
                          width: double.infinity,
                          child: _SecondaryMutualButton(
                            onTap: () {
                              final f = ref.read(friendsControllerProvider).selectedFriend;
                              if (f != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FriendGoalsPage(friend: f),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Removed legacy top bar; replaced with AppBar using GoalPage styling.

  // (fallback not used; base avatar always shown)

  // Old big button replaced by AppBar action + secondary button inside card.

  // Removed Coming Soon dialog since the feature is implemented.
}

class _FriendAvatarView extends StatelessWidget {
  final User friend;
  const _FriendAvatarView({required this.friend});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final avatarW = math.min(screenW * 0.55, AppConstants.avatarCostumeWidth);

    final String? headFile = friend.avatar?.equipped?.head?.picture;
    final String? bodyFile = friend.avatar?.equipped?.body?.picture;

    return SizedBox(
      width: avatarW,
      height: avatarW,
      child: Stack(
        children: [
          // Base avatar image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Avatar.png',
              fit: BoxFit.contain,
            ),
          ),

          // Head overlay
          if (headFile != null)
            Builder(builder: (context) {
              final hatWBase = avatarW * AppConstants.costumeHatWidthFactor;
              final hatScale = AppConstants.costumeScalesHome[headFile] ?? 1.0;
          // (removed misplaced helper widget definitions)
              final hatW = hatWBase * hatScale;
              final alignY = AppConstants.costumeHatAlignmentY;
              final centerY = avatarW * ((alignY + 1) / 2);
              final hatTop = centerY - (hatW / 2);
              final hatLeft = (avatarW - hatW) / 2;
              final norm =
                  AppConstants.costumeOffsetsHomeNormalized[headFile] ??
                      Offset.zero;
              final perOffset = Offset(norm.dx * avatarW, norm.dy * avatarW);
              return Positioned(
                left: hatLeft + perOffset.dx,
                top: hatTop + perOffset.dy,
                width: hatW,
                child: Image.asset(
                  'assets/images/$headFile',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              );
            }),

          // Body overlay
          if (bodyFile != null)
            Builder(builder: (context) {
              final bodyWBase = avatarW * AppConstants.costumeBodyWidthFactor;
              final bodyScale = AppConstants.costumeScalesHome[bodyFile] ?? 1.0;
              final bodyW = bodyWBase * bodyScale;
              final alignY = AppConstants.costumeBodyAlignmentY;
              final centerY = avatarW * ((alignY + 1) / 2);
              final top = centerY - (bodyW / 2);
              final left = (avatarW - bodyW) / 2;
              final norm =
                  AppConstants.costumeOffsetsHomeNormalized[bodyFile] ??
                      Offset.zero;
              final perOffset = Offset(norm.dx * avatarW, norm.dy * avatarW);
              return Positioned(
                left: left + perOffset.dx,
                top: top + perOffset.dy,
                width: bodyW,
                child: Image.asset(
                  'assets/images/$bodyFile',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// Helper widgets (moved outside of avatar view)
class _GradientCircleInitial extends StatelessWidget {
  final String text;
  const _GradientCircleInitial(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.pinkAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text.isNotEmpty ? text[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _MutualGoalsActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _MutualGoalsActionButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.purple, Colors.pinkAccent]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.flag_outlined, color: Colors.white),
        label: const Text(
          'Mutual',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _SecondaryMutualButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SecondaryMutualButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(colors: [Colors.purple, Colors.pinkAccent]),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.groups_2_outlined, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'View Mutual Goals',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
