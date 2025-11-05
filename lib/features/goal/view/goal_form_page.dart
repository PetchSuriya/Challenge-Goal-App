import 'package:flutter/material.dart';
import '../controller/goal_form_controller.dart';
import 'widgets/friend_selector_dialog.dart';
import 'widgets/date_range_picker_dialog.dart';
import 'widgets/goal_image_picker.dart';
import 'widgets/goal_title_field.dart';
import 'widgets/goal_duration_field.dart';
import 'widgets/goal_category_grid.dart';

/// GoalFormPage - หน้าฟอร์มสำหรับสร้างเป้าหมายใหม่
/// Refactored to use Controller and separate Widget components
class GoalFormPage extends StatefulWidget {
  const GoalFormPage({super.key});

  @override
  State<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends State<GoalFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final GoalFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GoalFormController();
    _controller.addListener(() {
      setState(() {}); // Rebuild when controller state changes
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showAddFriendDialog() async {
    final result = await FriendSelectorDialog.show(
      context: context,
      initialSelectedFriends: _controller.state.selectedFriends,
    );

    if (result != null) {
      _controller.updateSelectedFriends(result);
    }
  }

  Future<void> _submitForm() async {
    // Validate using controller
    final error = _controller.validateForm(_formKey);
    
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Submit using controller
      final goal = await _controller.submitGoal();
      
      if (!mounted) return;
      Navigator.of(context).pop(); // close progress
      Navigator.pop(context, goal);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add goal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7B68EE), Color(0xFFDA70D6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.flag,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Goal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Create your next achievement',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image, Goal Title, and Duration in same row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Picker (Left side) - Match height with Goal Title + Duration
                          GoalImagePicker(
                            selectedImage: _controller.state.selectedImage,
                            onTap: () => _controller.pickImage(),
                          ),
                          const SizedBox(width: 16),

                          // Goal Title and Duration (Right side)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Goal Title
                                GoalTitleField(controller: _controller.titleController),

                                const SizedBox(height: 12),

                                // Duration (Below Goal Title, same column)
                                GoalDurationField(
                                  controller: _controller.durationController,
                                  selectedDateRange: _controller.state.selectedDateRange,
                                  showError: _controller.state.showDateRangeError,
                                  onDateRangeChanged: (result) {
                                    if (result != null) {
                                      _controller.updateDateRange(result);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Category Section
                      GoalCategoryGrid(
                        selectedCategory: _controller.state.selectedCategory,
                        onCategorySelected: (category) => _controller.selectCategory(category),
                      ),

                      const SizedBox(height: 24),

                      // Goal Type Section
                      const Text(
                        'Goal Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _GoalTypeCard(
                              icon: Icons.person_outline,
                              title: 'Personal',
                              subtitle: 'Just for you',
                              isSelected: _controller.state.selectedGoalType == 'Personal',
                              onTap: () => _controller.selectGoalType('Personal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GoalTypeCard(
                              icon: Icons.people_outline,
                              title: 'Mutual',
                              subtitle: 'With a friend',
                              isSelected: _controller.state.selectedGoalType == 'Mutual',
                              onTap: () => _controller.selectGoalType('Mutual'),
                            ),
                          ),
                        ],
                      ),

                      // Add Friend Section (only show for Mutual)
                      if (_controller.state.selectedGoalType == 'Mutual') ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Add friend',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Display selected friends
                        ..._controller.state.selectedFriends.map(
                          (friend) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.purple.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.purple,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    friend,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _controller.removeFriend(friend),
                                  icon: const Icon(Icons.close),
                                  color: Colors.grey,
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Add Friend Button
                        OutlinedButton.icon(
                          onPressed: _showAddFriendDialog,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add friend'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
                        onPressed: _controller.state.showDateRangeError 
                            ? () {
                                // ไม่ทำอะไร - แค่ป้องกันไม่ให้ submit
                              }
                            : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Goal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
}

// Goal Type Card Widget
class _GoalTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade50 : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.purple.shade100
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.purple : Colors.grey.shade600,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.purple : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.purple.shade300
                          : Colors.grey.shade600,
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
}


