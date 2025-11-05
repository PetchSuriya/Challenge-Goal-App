import 'package:flutter/material.dart';
import '../../../../services/friends_service.dart';

/// Friend Selector Dialog - แยกออกจาก goal_form_page.dart
/// แสดง dialog สำหรับเลือกเพื่อนจากรายชื่อเพื่อนจริงใน database
class FriendSelectorDialog {
  /// แสดง dialog และ return รายชื่อเพื่อนที่เลือก
  static Future<List<String>?> show({
    required BuildContext context,
    required List<String> initialSelectedFriends,
  }) async {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Fetch real friends data from API
      final friendsService = FriendsService();
      final friendsData = await friendsService.getFriends();
      
      // Convert User objects to Map format for compatibility
      final List<Map<String, dynamic>> availableFriends = friendsData.friends
          .map((user) => {
                'id': user.id,
                'name': user.username,
                'avatar': '👤', // Default avatar, can be customized later
              })
          .toList();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // If no friends found, show message
      if (availableFriends.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have no friends yet. Add friends first!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return null;
      }

      // Show friend selection dialog
      if (!context.mounted) return null;
      
      return await showDialog<List<String>>(
        context: context,
        builder: (context) => _FriendSelectorDialogContent(
          availableFriends: availableFriends,
          initialSelectedFriends: initialSelectedFriends,
        ),
      );
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.pop(context);
      
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load friends: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }
}

/// Dialog content widget
class _FriendSelectorDialogContent extends StatefulWidget {
  final List<Map<String, dynamic>> availableFriends;
  final List<String> initialSelectedFriends;

  const _FriendSelectorDialogContent({
    required this.availableFriends,
    required this.initialSelectedFriends,
  });

  @override
  State<_FriendSelectorDialogContent> createState() =>
      _FriendSelectorDialogContentState();
}

class _FriendSelectorDialogContentState
    extends State<_FriendSelectorDialogContent> {
  late TextEditingController searchController;
  late List<String> tempSelectedFriends;
  late List<Map<String, dynamic>> filteredFriends;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    tempSelectedFriends = List.from(widget.initialSelectedFriends);
    filteredFriends = List.from(widget.availableFriends);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFriends = List.from(widget.availableFriends);
      } else {
        filteredFriends = widget.availableFriends
            .where(
              (friend) => friend['name'].toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Add friend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Search Field
            TextField(
              controller: searchController,
              onChanged: _filterFriends,
              decoration: InputDecoration(
                hintText: 'Enter friend name or e.g. john doe, jane doe',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF7B68EE),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Friends List
            Flexible(
              child: filteredFriends.isEmpty
                  ? Center(
                      child: Text(
                        'No friends found',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: (filteredFriends.length / 2).ceil(),
                      itemBuilder: (context, index) {
                        final leftIndex = index * 2;
                        final rightIndex = leftIndex + 1;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              // Left column
                              Expanded(
                                child: _FriendCheckboxItem(
                                  name: filteredFriends[leftIndex]['name'],
                                  avatar: filteredFriends[leftIndex]['avatar'],
                                  isSelected: tempSelectedFriends.contains(
                                    filteredFriends[leftIndex]['name'],
                                  ),
                                  onChanged: (selected) {
                                    setState(() {
                                      if (selected) {
                                        tempSelectedFriends.add(
                                          filteredFriends[leftIndex]['name'],
                                        );
                                      } else {
                                        tempSelectedFriends.remove(
                                          filteredFriends[leftIndex]['name'],
                                        );
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Right column
                              if (rightIndex < filteredFriends.length)
                                Expanded(
                                  child: _FriendCheckboxItem(
                                    name: filteredFriends[rightIndex]['name'],
                                    avatar: filteredFriends[rightIndex]
                                        ['avatar'],
                                    isSelected: tempSelectedFriends.contains(
                                      filteredFriends[rightIndex]['name'],
                                    ),
                                    onChanged: (selected) {
                                      setState(() {
                                        if (selected) {
                                          tempSelectedFriends.add(
                                            filteredFriends[rightIndex]['name'],
                                          );
                                        } else {
                                          tempSelectedFriends.remove(
                                            filteredFriends[rightIndex]['name'],
                                          );
                                        }
                                      });
                                    },
                                  ),
                                )
                              else
                                const Expanded(child: SizedBox()),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B68EE), Color(0xFFDA70D6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, tempSelectedFriends);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Friend Checkbox Item Widget
class _FriendCheckboxItem extends StatelessWidget {
  final String name;
  final String avatar;
  final bool isSelected;
  final Function(bool) onChanged;

  const _FriendCheckboxItem({
    required this.name,
    required this.avatar,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF7B68EE) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: Text(avatar, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
            // Name
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: (value) => onChanged(value ?? false),
              activeColor: const Color(0xFF7B68EE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
