// lib/widgets/category_badge.dart
import 'package:flutter/material.dart';
import '../utils/category_colors.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  final double size;

  const CategoryBadge({
    Key? key,
    required this.category,
    this.size = 32,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = CategoryColors.getCategory(category);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: categoryColor.color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: categoryColor.color,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          categoryColor.icon,
          color: categoryColor.color,
          size: size * 0.6,
        ),
      ),
    );
  }
}

// Extended version with label
class CategoryBadgeWithLabel extends StatelessWidget {
  final String category;

  const CategoryBadgeWithLabel({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = CategoryColors.getCategory(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColor.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: categoryColor.color.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryColor.icon,
            color: categoryColor.color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            categoryColor.label,
            style: TextStyle(
              color: categoryColor.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
