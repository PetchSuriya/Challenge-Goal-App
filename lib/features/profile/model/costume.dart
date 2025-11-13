
/// Costume domain model representing an avatar customization item.
/// Uses filename as stable id for persistence simplicity.
class Costume {
  final String id; // e.g. hat_green.png
  final String type; // 'head' or 'body'
  final String name; // Human readable: "Green Hat"
  final String assetPath; // assets/images/hat_green.png
  bool isUnlocked;
  bool isEquipped; // true if currently worn

  Costume({
    required this.id,
    required this.type,
    required this.name,
    required this.assetPath,
    this.isUnlocked = false,
    this.isEquipped = false,
  });

  Costume copyWith({
    bool? isUnlocked,
    bool? isEquipped,
  }) => Costume(
        id: id,
        type: type,
        name: name,
        assetPath: assetPath,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        isEquipped: isEquipped ?? this.isEquipped,
      );
}
