import 'dart:io';
import 'package:flutter/material.dart';

/// Goal Image Picker Widget
class GoalImagePicker extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onTap;

  const GoalImagePicker({
    super.key,
    required this.selectedImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        constraints: const BoxConstraints(
          minHeight: 180,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: Colors.grey.shade400,
                    size: 40,
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }
}
