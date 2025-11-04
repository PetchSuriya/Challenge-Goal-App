import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../controller/home_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _savedCostume;
  @override
  void initState() {
    super.initState();
    // Initialize the home controller when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).initialize();
    });
    // load saved costume
    _loadSavedCostume();
  }

  Future<void> _loadSavedCostume() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.selectedCostumeKey);
    setState(() {
      _savedCostume = saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavigation(context),

            // Main Content Area
            Expanded(
              child: Stack(
                children: [
                  // Avatar centered in the available space
                  Center(
                    child: Container(
                      width: AppConstants.avatarCostumeWidth,
                      height: AppConstants.avatarCostumeWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                          children: [
                            // Avatar base
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/Avatar.png',
                                width: AppConstants.avatarCostumeWidth,
                                height: AppConstants.avatarCostumeWidth,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildFallbackAvatar();
                                },
                              ),
                            ),

                            // Hat overlay placed in the same layer and positioned relative
                            // to the avatar using the shared alignment and per-costume offsets.
                            if (_savedCostume != null)
                              Builder(
                                builder: (context) {
                                  final avatarW =
                                      AppConstants.avatarCostumeWidth;
                                  final avatarH = avatarW; // square avatar
                                  final hatW =
                                      avatarW *
                                      AppConstants.costumeHatWidthFactor;
                                  final alignY =
                                      AppConstants.costumeHatAlignmentY;

                                  // alignmentY (-1..1) -> fraction from top (0..1)
                                  final fracFromTop = (alignY + 1) / 2;

                                  // center Y position in pixels where the hat's center should be
                                  final centerY = avatarH * fracFromTop;

                                  // top-left for the hat so that its center is at centerY
                                  final hatTop = centerY - (hatW / 2);
                                  final hatLeft = (avatarW - hatW) / 2;

                                  // Apply per-costume pixel nudges (x, y)
                                  final perOffset =
                                      AppConstants
                                          .costumeOffsets[_savedCostume ??
                                          ''] ??
                                      Offset.zero;

                                  return Positioned(
                                    left: hatLeft + perOffset.dx,
                                    top: hatTop + perOffset.dy,
                                    width: hatW,
                                    child: Image.asset(
                                      'assets/images/$_savedCostume',
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const SizedBox.shrink(),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                  // Goal Button at bottom with more margin to give avatar space
                  Positioned(
                    bottom: 60,
                    left: 24,
                    right: 24,
                    child: _buildGoalButton(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      // No white background - transparent
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Button (Top Left)
          _buildSquareButton(
            icon: Icons.person_outline,
            label: 'Profile',
            color: Colors.blue.shade600,
            onTap: () => context.go(AppConstants.profileRoute),
          ),

          const Spacer(),

          // Friends Button (Center) - medium width
          Column(
            children: [
              const SizedBox(height: 10), // Align with other buttons
              _buildFriendsButton(context),
            ],
          ),

          const Spacer(),

          // Costume Button (Top Right)
          Column(
            children: [
              _buildSquareButton(
                icon: Icons.style_outlined,
                label: 'Costume',
                color: Colors.purple.shade600,
                onTap: () {
                  context.go(AppConstants.costumeRoute);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSquareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsButton(BuildContext context) {
    return Container(
      width: 160, // Medium width instead of full width
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade500, Colors.green.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to friend page
          context.go(AppConstants.friendRoute);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Friends',
              style: TextStyle(
                fontSize: 16,
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

  Widget _buildGoalButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.purple.shade600],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Navigate directly to Goals page
          context.go(AppConstants.goalRoute);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Goals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: AppConstants.avatarCostumeWidth,
      height: AppConstants.avatarCostumeWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade400],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Avatar not found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Place avatar.png in assets/images/',
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}
