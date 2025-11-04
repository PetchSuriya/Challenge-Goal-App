import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class CostumePage extends StatefulWidget {
  const CostumePage({super.key});

  @override
  State<CostumePage> createState() => _CostumePageState();
}

class _CostumePageState extends State<CostumePage> {
  // Hardcoded list of costume asset filenames (now located in assets/images/)
  final List<String> _costumeFiles = [
    'Green_hat.png',
    'Red_hat.png',
    'White_hat.png',
    'Black_suit.png',
    'Blue_suit.png',
    'Brown_suit.png',
    'Blue_shoes.png',
    'Brown_shoes.png',
    'Grey_shoes.png',
  ];

  int _windowStart =
      0; // index for the leftmost visible costume (show 3 at a time)
  String?
  _previewCostume; // currently previewed costume filename (not yet saved)

  @override
  void initState() {
    super.initState();
    _loadSavedCostume();
  }

  // Helper to accept either a full asset path or a filename stored in preferences.
  String _assetPath(String name) {
    if (name.startsWith('assets/')) return name;
    final mapped = AppConstants.costumeNameMap[name];
    final file = mapped ?? name;
    return 'assets/images/$file';
  }

  Future<void> _loadSavedCostume() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.selectedCostumeKey);
    if (!mounted) return;
    setState(() {
      _previewCostume = saved;
    });
  }

  Future<void> _saveCostume() async {
    final prefs = await SharedPreferences.getInstance();
    if (_previewCostume == null) {
      await prefs.remove(AppConstants.selectedCostumeKey);
    } else {
      await prefs.setString(AppConstants.selectedCostumeKey, _previewCostume!);
    }
    // After saving, navigate back to dashboard/home
    if (!mounted) return;
    context.go(AppConstants.dashboardRoute);
  }

  void _moveLeft() {
    setState(() {
      _windowStart = (_windowStart - 1).clamp(0, _costumeFiles.length - 3);
    });
  }

  void _moveRight() {
    setState(() {
      _windowStart = (_windowStart + 1).clamp(0, _costumeFiles.length - 3);
    });
  }

  void _selectPreview(String fileName) {
    setState(() {
      _previewCostume = fileName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _costumeFiles.skip(_windowStart).take(3).toList();

    // Use shared constants for avatar and hat sizing so positioning matches HomePage
    final double avatarWidth = AppConstants.avatarCostumeWidth;

    // Determine asset type: suit, shoe or hat
    bool isSuit(String? name) {
      if (name == null) return false;
      final lower = name.toLowerCase();
      return lower.contains('suit');
    }

    bool isShoe(String? name) {
      if (name == null) return false;
      final lower = name.toLowerCase();
      return lower.contains('shoe') || lower.contains('shoes');
    }

    String _basename(String? name) {
      if (name == null) return '';
      if (name.startsWith('assets/')) return name.split('/').last;
      return name;
    }

    final previewIsSuit = isSuit(_previewCostume);
    final previewIsShoe = isShoe(_previewCostume);
    final double hatWidth =
        (avatarWidth *
                (previewIsSuit
                    ? AppConstants.costumeSuitWidthFactor
                    : (previewIsShoe
                          ? AppConstants.costumeShoeWidthFactor
                          : AppConstants.costumeHatWidthFactor)) *
                (previewIsSuit
                    ? AppConstants.costumeSuitScale
                    : (previewIsShoe
                          ? AppConstants.costumeShoeScale
                          : AppConstants.costumeHatScale)))
            .roundToDouble();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with previous and save
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  // Previous (back to dashboard)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => context.go(AppConstants.dashboardRoute),
                  ),
                  const Spacer(),

                  // Clear button - clears previewed costume (user must press Save to persist removal)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _previewCostume = null;
                      });
                    },
                    child: const Text('Clear'),
                  ),

                  const SizedBox(width: 8),

                  // Save button
                  TextButton(
                    onPressed: _saveCostume,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),

            // Avatar with preview overlay
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Avatar base (match actual filename casing)
                    Image.asset(
                      'assets/images/Avatar.png',
                      width: avatarWidth,
                      height: avatarWidth,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.person, size: 48),
                            SizedBox(height: 8),
                            Text('Avatar missing'),
                          ],
                        ),
                      ),
                    ),

                    // Hat preview - align towards top of avatar and scale relative to avatar size
                    if (_previewCostume != null)
                      Builder(
                        builder: (context) {
                          final basename = _basename(_previewCostume);
                          final per =
                              AppConstants.costumeOffsetsCostume[basename] ??
                              Offset.zero;
                          final scaledPer = Offset(
                            per.dx *
                                (previewIsSuit
                                    ? AppConstants.costumeSuitScale
                                    : (previewIsShoe
                                          ? AppConstants.costumeShoeScale
                                          : AppConstants.costumeHatScale)),
                            per.dy *
                                (previewIsSuit
                                    ? AppConstants.costumeSuitScale
                                    : (previewIsShoe
                                          ? AppConstants.costumeShoeScale
                                          : AppConstants.costumeHatScale)),
                          );
                          final lap =
                              AppConstants.costumeLapOffsetY *
                              (previewIsSuit
                                  ? AppConstants.costumeSuitScale
                                  : (previewIsShoe
                                        ? AppConstants.costumeShoeScale
                                        : AppConstants.costumeHatScale));

                          // Choose alignment based on asset type (suit/shoe/hat)
                          final alignY = previewIsSuit
                              ? AppConstants.costumeSuitAlignmentY
                              : (previewIsShoe
                                    ? AppConstants.costumeShoeAlignmentY
                                    : AppConstants.costumeHatAlignmentY);

                          return Align(
                            alignment: Alignment(0, alignY),
                            child: SizedBox(
                              width: hatWidth,
                              child: Transform.translate(
                                offset: scaledPer + Offset(0, lap),
                                child: Image.asset(
                                  _assetPath(_previewCostume ?? ''),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.error,
                                              color: Colors.red,
                                              size: 28,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Failed to load: $_previewCostume',
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 10,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // (Removed preview filename debug UI)
            const SizedBox(height: 12),

            // Costume selection row with arrows
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left arrow
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 36),
                    onPressed: _windowStart > 0 ? _moveLeft : null,
                  ),

                  // Thumbnails
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: visible.map((file) {
                        final fullPath = _assetPath(file);
                        final selected = file == _previewCostume;
                        return GestureDetector(
                          onTap: () => _selectPreview(file),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  border: selected
                                      ? Border.all(color: Colors.blue, width: 3)
                                      : Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Image.asset(
                                    fullPath,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) => Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                file.split('.').first.replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selected
                                      ? Colors.black
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Right arrow
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 36),
                    onPressed: _windowStart < (_costumeFiles.length - 3)
                        ? _moveRight
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
