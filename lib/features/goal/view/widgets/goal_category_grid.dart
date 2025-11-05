import 'package:flutter/material.dart';
import '../../model/goal_form_state.dart';

/// Goal Category Grid Widget
class GoalCategoryGrid extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const GoalCategoryGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: GoalCategory.categories.length,
          itemBuilder: (context, index) {
            final category = GoalCategory.categories[index];
            final isSelected = selectedCategory == category.name;

            return _CategoryCard(
              category: category,
              isSelected: isSelected,
              onTap: () => onCategorySelected(category.name),
            );
          },
        ),
      ],
    );
  }
}

/// Category Card Widget
class _CategoryCard extends StatelessWidget {
  final GoalCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade50 : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.purple.shade100
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: isSelected ? Colors.purple : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              category.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.purple : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
