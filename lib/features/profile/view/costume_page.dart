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
    'Black_Cap.png',
    'Blue_Cap.png',
    'Green_Cap.png',
    'Red_Hat.png',
    'White_Hat.png',
    'Yellow_Hat.png',
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
    final double hatWidth = (avatarWidth * AppConstants.costumeHatWidthFactor)
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
                    // Avatar base
                    Image.asset(
                      'assets/images/avatar.png',
                      width: avatarWidth,
                      height: avatarWidth,
                      fit: BoxFit.contain,
                    ),

                    // Hat preview - align towards top of avatar and scale relative to avatar size
                    if (_previewCostume != null)
                      Align(
                        alignment: Alignment(
                          0,
                          AppConstants.costumeHatAlignmentY,
                        ),
                        child: SizedBox(
                          width: hatWidth,
                          child: Transform.translate(
                            offset:
                                (AppConstants.costumeOffsets[_previewCostume ??
                                        ''] ??
                                    const Offset(0, 0)) +
                                Offset(0, AppConstants.costumeLapOffsetY),
                            child: Image.asset(
                              'assets/images/$_previewCostume',
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
                      ),
                  ],
                ),
              ),
            ),

            // Debug / status: show current preview filename (helpful when assets don't appear)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _previewCostume == null
                        ? 'Preview: (none)'
                        : 'Preview: ${_previewCostume!}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),

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
                        final fullPath = 'assets/images/$file';
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
