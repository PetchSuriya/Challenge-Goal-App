import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Simple repository for managing unlocked costume filenames in local storage.
///
/// Locked set is derived from [AppConstants.defaultLockedCostumes]. Any item
/// in that list is considered locked until present in the owned list saved in
/// [AppConstants.ownedCostumesKey]. Items not in the default locked list are
/// considered always available.
class CostumeRepository {
  static final CostumeRepository _instance = CostumeRepository._();
  factory CostumeRepository() => _instance;
  CostumeRepository._();

  Future<Set<String>> getOwned() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(AppConstants.ownedCostumesKey) ?? <String>[];
    return list.toSet();
  }

  Future<void> addOwned(String filename) async {
    final prefs = await SharedPreferences.getInstance();
    final set = await getOwned();
    if (!set.contains(filename)) {
      set.add(filename);
      await prefs.setStringList(AppConstants.ownedCostumesKey, set.toList());
    }
  }

  /// Returns the filename of the unlocked costume, or null if none available.
  Future<String?> unlockRandom() async {
    final owned = await getOwned();
    final locked = AppConstants.defaultLockedCostumes
        .where((f) => !owned.contains(f))
        .toList(growable: false);
    if (locked.isEmpty) return null;
    final rng = Random();
    final pick = locked[rng.nextInt(locked.length)];
    await addOwned(pick);
    return pick;
  }
}
