import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import 'dart:math' as math;
import '../../../services/costume_repository.dart';

class CostumePage extends StatefulWidget {
  const CostumePage({super.key});

  @override
  State<CostumePage> createState() => _CostumePageState();
}

class _CostumePageState extends State<CostumePage>
    with SingleTickerProviderStateMixin {
  // Per-slot costume lists populated from assets/images/.
  // We'll populate these lists at runtime by reading AssetManifest.json so
  // we don't have to maintain hard-coded filenames.
  final Map<String, List<String>> _costumesBySlot = {'head': [], 'body': []};

  late final TabController _tabController;
  int _currentTabIndex = 0; // 0=head,1=body

  // preview (not-saved) and saved maps per slot
  final Map<String, String?> _previewBySlot = {'head': null, 'body': null};
  final Map<String, String?> _savedBySlot = {'head': null, 'body': null};
  // Owned/unlocked costumes stored persistently. If a costume is in the
  // AppConstants.defaultLockedCostumes list but not in this set, it is
  // considered locked and cannot be selected.
  final Set<String> _ownedCostumes = <String>{};

  static const List<String> _slots = ['head', 'body'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _slots.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    // Populate costume lists from bundled assets, then load saved selections.
    _populateCostumesFromAssetManifest().then((_) async {
      await _sanitizeSavedCostumes();
      await _loadSavedCostumes();
      await _loadOwnedCostumes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Populate `_costumesBySlot` by reading the Flutter AssetManifest.
  /// This allows adding/removing costume files in `assets/images/` without
  /// updating code. Filenames containing 'avatar' are ignored.
  Future<void> _populateCostumesFromAssetManifest() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final imageKeys = manifestMap.keys.where((k) {
        return k.startsWith('assets/images/') &&
            (k.endsWith('.png') || k.endsWith('.jpg') || k.endsWith('.webp'));
      }).toList();

      // Clear existing lists
      _costumesBySlot['head']!.clear();
      _costumesBySlot['body']!.clear();

      for (final key in imageKeys) {
        final filename = key.split('/').last;
        final lower = filename.toLowerCase();

        // Skip avatar images
        if (lower.contains('avatar')) continue;

        // Heuristic classification
        // - caps/hats => head
        // - suits/dresses => body
        // - shoes and high-heels are intentionally skipped entirely when the
        //   "foot" slot is removed so they don't appear anywhere in the UI.
        if (lower.contains('cap') || lower.contains('hat')) {
          _costumesBySlot['head']!.add(filename);
        } else if (lower.contains('hh') || lower.endsWith('_hh.png')) {
          // Skip high-heels images (e.g. 'abc_hh.png') entirely so they
          // don't appear in the CostumePage selection.
          continue;
        } else if (lower.contains('shoe') || lower.contains('shoes')) {
          // Previously shoes were skipped when the foot slot existed or
          // was removed. Treat shoes as body costumes so they appear in the
          // Body tab (they will be positioned with the body offsets/scales).
          _costumesBySlot['body']!.add(filename);
        } else if (lower.contains('suit') || lower.contains('dress')) {
          _costumesBySlot['body']!.add(filename);
        } else {
          // fallback: add to body
          _costumesBySlot['body']!.add(filename);
        }
      }

      // Sort lists for deterministic order
      _costumesBySlot.forEach((k, v) => v.sort((a, b) => a.compareTo(b)));

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      // If AssetManifest is unavailable for some reason, keep the lists empty.
      // We intentionally swallow errors to avoid crashing on asset read.
      // Consider logging the error in the future.
    }
  }

  Future<void> _loadSavedCostumes() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _savedBySlot['head'] = prefs.getString(
        AppConstants.selectedCostumeHeadKey,
      );
      _savedBySlot['body'] = prefs.getString(
        AppConstants.selectedCostumeBodyKey,
      );
      // default preview mirrors saved selection
      _previewBySlot['head'] = _savedBySlot['head'];
      _previewBySlot['body'] = _savedBySlot['body'];
    });
  }

  Future<void> _loadOwnedCostumes() async {
    final repo = CostumeRepository();
    final owned = await repo.getOwned();
    // Ensure currently saved items remain owned
    final adjusted = owned.toSet();
    if (_savedBySlot['head'] != null) adjusted.add(_savedBySlot['head']!);
    if (_savedBySlot['body'] != null) adjusted.add(_savedBySlot['body']!);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.ownedCostumesKey, adjusted.toList());
    _ownedCostumes
      ..clear()
      ..addAll(adjusted);
    if (mounted) setState(() {});
  }

  // Ensure saved costume filenames actually exist in the populated costume
  // lists. If a saved filename is missing (file deleted), remove the pref so
  // we don't attempt to load a non-existent asset.
  Future<void> _sanitizeSavedCostumes() async {
    final prefs = await SharedPreferences.getInstance();

    // Build a set of available filenames from the populated lists.
    final available = <String>{};
    for (final list in _costumesBySlot.values) {
      for (final f in list) available.add(f);
    }

    // Head
    final headPref = prefs.getString(AppConstants.selectedCostumeHeadKey);
    if (headPref != null &&
        available.isNotEmpty &&
        !available.contains(headPref)) {
      await prefs.remove(AppConstants.selectedCostumeHeadKey);
      _savedBySlot['head'] = null;
      _previewBySlot['head'] = null;
    }

    // Body
    final bodyPref = prefs.getString(AppConstants.selectedCostumeBodyKey);
    if (bodyPref != null &&
        available.isNotEmpty &&
        !available.contains(bodyPref)) {
      await prefs.remove(AppConstants.selectedCostumeBodyKey);
      _savedBySlot['body'] = null;
      _previewBySlot['body'] = null;
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveAllSlots() async {
    final prefs = await SharedPreferences.getInstance();
    // Persist both head and body using current preview selections
    for (final slot in _slots) {
      final val = _previewBySlot[slot];
      final key = _slotToKey(slot);
      if (val == null) {
        await prefs.remove(key);
        _savedBySlot[slot] = null;
      } else {
        await prefs.setString(key, val);
        _savedBySlot[slot] = val;
      }
    }
    if (!mounted) return;
    // After saving, navigate back to dashboard/home
    context.go(AppConstants.dashboardRoute);
  }

  String _slotToKey(String slot) {
    switch (slot) {
      case 'head':
        return AppConstants.selectedCostumeHeadKey;
      case 'body':
        return AppConstants.selectedCostumeBodyKey;
      default:
        return AppConstants.selectedCostumeKey;
    }
  }

  void _selectPreviewForSlot(String slot, String file) {
    setState(() {
      _previewBySlot[slot] = file;
    });
  }

  Future<void> _clearAllSlots() async {
    // Clear both preview and saved selections and persist removal
    final prefs = await SharedPreferences.getInstance();
    for (final slot in _slots) {
      _previewBySlot[slot] = null;
      _savedBySlot[slot] = null;
    }
    await prefs.remove(AppConstants.selectedCostumeHeadKey);
    await prefs.remove(AppConstants.selectedCostumeBodyKey);
    if (!mounted) return;
    setState(() {});
  }

  Widget _buildOverlayFor(String file, String slot, double avatarWidth) {
    double width = avatarWidth * AppConstants.costumeHatWidthFactor;
    double alignX = 0;
    double alignY = AppConstants.costumeHatAlignmentY;

    // Only head and body slots exist now.
    if (slot == 'body') {
      width = avatarWidth * AppConstants.costumeBodyWidthFactor;
      alignY = AppConstants.costumeBodyAlignmentY;
    }

    // Apply per-costume scale if provided (scales the computed width).
    final perScale = AppConstants.costumeScalesPreview[file] ?? 1.0;
    width = width * perScale;

    // Use normalized offsets (fractions of avatar width) so placement adapts
    // to different device sizes. Convert to pixels by multiplying by avatarWidth.
    final norm =
        AppConstants.costumeOffsetsPreviewNormalized[file] ?? Offset.zero;
    final perOffset = Offset(norm.dx * avatarWidth, norm.dy * avatarWidth);
    final lapPx = AppConstants.costumeLapOffsetYNormalized * avatarWidth;

    return Align(
      alignment: Alignment(alignX, alignY),
      child: SizedBox(
        width: width,
        child: Transform.translate(
          offset: perOffset + Offset(0, lapPx),
          child: Image.asset(
            'assets/images/$file',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slot = _slots[_currentTabIndex];
    final available = _costumesBySlot[slot] ?? [];

    final screenW = MediaQuery.of(context).size.width;
    final double avatarWidth = math.min(
      screenW * 0.55,
      AppConstants.avatarCostumeWidth,
    );

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => context.go(AppConstants.dashboardRoute),
                  ),
                  const Spacer(),

                  // Clear button - clears preview for BOTH slots (user must press Save to persist)
                  TextButton(
                    onPressed: _clearAllSlots,
                    child: const Text('Clear'),
                  ),

                  const SizedBox(width: 8),

                  // Save button - saves BOTH head and body selections
                  TextButton(
                    onPressed: _saveAllSlots,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),

            // Slot tabs
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Head'),
                Tab(text: 'Body'),
              ],
            ),

            // Avatar with preview & saved overlays
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Avatar base (use exact filename present in assets/images)
                    Image.asset(
                      'assets/images/Avatar.png',
                      width: avatarWidth,
                      height: avatarWidth,
                      fit: BoxFit.contain,
                    ),

                    // Head overlay (preview if set else saved)
                    if ((_previewBySlot['head'] ?? _savedBySlot['head']) !=
                        null)
                      _buildOverlayFor(
                        _previewBySlot['head'] ?? _savedBySlot['head']!,
                        'head',
                        avatarWidth,
                      ),

                    // Body overlay
                    if ((_previewBySlot['body'] ?? _savedBySlot['body']) !=
                        null)
                      _buildOverlayFor(
                        _previewBySlot['body'] ?? _savedBySlot['body']!,
                        'body',
                        avatarWidth,
                      ),
                  ],
                ),
              ),
            ),

            // (Preview status text removed by request)
            const SizedBox(height: 12),

            // Costume selection area for the current slot
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Available ${slot[0].toUpperCase()}${slot.substring(1)} costumes',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (available.isEmpty)
                    Container(
                      height: 110,
                      alignment: Alignment.center,
                      child: Text(
                        'No costumes available for $slot. Add images to assets/images and list filenames in this page to enable.',
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: available.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final file = available[index];
                          final selected = _previewBySlot[slot] == file;
                          final isDefaultLocked = AppConstants
                              .defaultLockedCostumes
                              .contains(file);
                          final isLocked =
                              isDefaultLocked && !_ownedCostumes.contains(file);
                          return GestureDetector(
                            onTap: () {
                              if (isLocked) {
                                // Inform the user how to unlock
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'This costume is locked. Complete goals to unlock rewards.',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              _selectPreviewForSlot(slot, file);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        border: selected
                                            ? Border.all(
                                                color: Colors.blue,
                                                width: 3,
                                              )
                                            : Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                        borderRadius: BorderRadius.circular(12),
                                        color: isLocked
                                            ? Colors.grey.shade100
                                            : null,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: isLocked
                                            // Show a blank area for locked costumes
                                            ? const SizedBox.shrink()
                                            : Image.asset(
                                                'assets/images/$file',
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Center(
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors
                                                            .grey
                                                            .shade400,
                                                      ),
                                                    ),
                                              ),
                                      ),
                                    ),
                                    if (isLocked)
                                      Positioned.fill(
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.35,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.lock,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isLocked
                                      ? 'Locked'
                                      : file
                                            .split('.')
                                            .first
                                            .replaceAll('_', ' '),
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
                        },
                      ),
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
