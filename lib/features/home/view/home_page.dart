import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../controller/home_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Saved/equipped costumes per slot
  Map<String, String?> _savedBySlot = {'head': null, 'body': null};
  @override
  void initState() {
    super.initState();
    // Initialize the home controller when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).initialize();
    });
    // load saved costumes (head/body)
    _loadSavedCostumes();
  }

  Future<void> _loadSavedCostumes() async {
    final prefs = await SharedPreferences.getInstance();

    // Load AssetManifest and build the set of available filenames so we can
    // validate persisted values (avoid trying to load missing assets).
    Set<String> available = <String>{};
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      for (final k in manifestMap.keys) {
        if (k.startsWith('assets/images/') &&
            (k.endsWith('.png') || k.endsWith('.jpg') || k.endsWith('.webp'))) {
          available.add(k.split('/').last);
        }
      }
    } catch (e) {
      // If we can't read the manifest, fall back to trusting prefs.
      available = <String>{};
    }

    // Read values from prefs
    final headVal = prefs.getString(AppConstants.selectedCostumeHeadKey);
    final bodyVal = prefs.getString(AppConstants.selectedCostumeBodyKey);

    // If persisted value points to a missing asset, remove it (cleanup) and
    // treat as null so we don't attempt to load a non-existent file.
    String? headSanitized = headVal;
    if (headSanitized != null &&
        available.isNotEmpty &&
        !available.contains(headSanitized)) {
      await prefs.remove(AppConstants.selectedCostumeHeadKey);
      headSanitized = null;
    }

    String? bodySanitized = bodyVal;
    if (bodySanitized != null &&
        available.isNotEmpty &&
        !available.contains(bodySanitized)) {
      await prefs.remove(AppConstants.selectedCostumeBodyKey);
      bodySanitized = null;
    }

    if (!mounted) return;
    setState(() {
      _savedBySlot['head'] = headSanitized;
      _savedBySlot['body'] = bodySanitized;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Compute a responsive avatar width: use up to 55% of screen width but
    // cap at the configured maximum (AppConstants.avatarCostumeWidth).
    // Reduced from 60% to 55% so avatar overlays have more room
    // before reaching the bottom controls on smaller screens.
    final screenW = MediaQuery.of(context).size.width;
    final avatarW = math.min(screenW * 0.55, AppConstants.avatarCostumeWidth);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavigation(context),

            // Main Content Area
            Expanded(
              child: Stack(
                children: [
                  // Goal Button at bottom. Use the device safe-area bottom inset
                  // so the button sits lower on devices with on-screen nav bars
                  // and doesn't overlap avatar overlays.
                  Positioned(
                    bottom: MediaQuery.of(context).viewPadding.bottom + 12,
                    left: 16,
                    right: 16,
                    child: SizedBox(
                      height: 64, // slightly smaller to reduce overlap
                      child: _buildGoalButton(context),
                    ),
                  ),

                  // Avatar raised up (closer to the top navigation / Friends button)
                  Align(
                    // Move avatar slightly lower (less negative) so overlays
                    // have more vertical room and are not clipped or
                    // overlapped by bottom buttons.
                    alignment: const Alignment(0, -0.45),
                    child: IgnorePointer(
                      // Allow taps to pass through to buttons beneath when
                      // avatar overlays overlap interactive controls.
                      ignoring: true,
                      child: SizedBox(
                        width: avatarW,
                        height: avatarW,
                        // No background or shadow: show avatar directly on page
                        child: Stack(
                          children: [
                            // Avatar base
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/Avatar.png',
                                width: avatarW,
                                height: avatarW,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildFallbackAvatar();
                                },
                              ),
                            ),

                            // Overlays for head and body (if present)
                            // Head
                            if (_savedBySlot['head'] != null)
                              Builder(
                                builder: (context) {
                                  final avatarH = avatarW;
                                  final hatWBase =
                                      avatarW *
                                      AppConstants.costumeHatWidthFactor;
                                  final hatScale =
                                      AppConstants
                                          .costumeScalesHome[_savedBySlot['head'] ??
                                          ''] ??
                                      1.0;
                                  final hatW = hatWBase * hatScale;
                                  final alignY =
                                      AppConstants.costumeHatAlignmentY;
                                  final fracFromTop = (alignY + 1) / 2;
                                  final centerY = avatarH * fracFromTop;
                                  final hatTop = centerY - (hatW / 2);
                                  final hatLeft = (avatarW - hatW) / 2;
                                  final norm =
                                      AppConstants
                                          .costumeOffsetsHomeNormalized[_savedBySlot['head'] ??
                                          ''] ??
                                      Offset.zero;
                                  final perOffset = Offset(
                                    norm.dx * avatarW,
                                    norm.dy * avatarW,
                                  );
                                  return Positioned(
                                    left: hatLeft + perOffset.dx,
                                    top: hatTop + perOffset.dy,
                                    width: hatW,
                                    child: Image.asset(
                                      'assets/images/${_savedBySlot['head']}',
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const SizedBox.shrink(),
                                    ),
                                  );
                                },
                              ),

                            // Body
                            if (_savedBySlot['body'] != null)
                              Builder(
                                builder: (context) {
                                  final bodyWBase =
                                      avatarW *
                                      AppConstants.costumeBodyWidthFactor;
                                  final bodyScale =
                                      AppConstants
                                          .costumeScalesHome[_savedBySlot['body'] ??
                                          ''] ??
                                      1.0;
                                  final bodyW = bodyWBase * bodyScale;
                                  final alignY =
                                      AppConstants.costumeBodyAlignmentY;
                                  final fracFromTop = (alignY + 1) / 2;
                                  final centerY = avatarW * fracFromTop;
                                  final top = centerY - (bodyW / 2);
                                  final left = (avatarW - bodyW) / 2;
                                  final norm =
                                      AppConstants
                                          .costumeOffsetsHomeNormalized[_savedBySlot['body'] ??
                                          ''] ??
                                      Offset.zero;
                                  final perOffset = Offset(
                                    norm.dx * avatarW,
                                    norm.dy * avatarW,
                                  );
                                  return Positioned(
                                    left: left + perOffset.dx,
                                    top: top + perOffset.dy,
                                    width: bodyW,
                                    child: Image.asset(
                                      'assets/images/${_savedBySlot['body']}',
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
    final screenW = MediaQuery.of(context).size.width;
    final width = math.min(screenW * 0.6, AppConstants.avatarCostumeWidth);

    return Container(
      width: width,
      height: width,
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
