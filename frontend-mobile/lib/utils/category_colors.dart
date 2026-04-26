// lib/utils/category_colors.dart
import 'package:flutter/material.dart';

class CategoryColor {
  final Color color;
  final IconData icon;
  final String label;

  CategoryColor({
    required this.color,
    required this.icon,
    required this.label,
  });
}

class CategoryColors {
  static final Map<String, CategoryColor> categoryMap = {
    'URGENT': CategoryColor(
      color: Colors.red,
      icon: Icons.warning_rounded,
      label: 'ด่วน',
    ),
    'GENERAL': CategoryColor(
      color: Colors.blue,
      icon: Icons.info_rounded,
      label: 'ข่าวสาร',
    ),
    'FINANCE': CategoryColor(
      color: Colors.green,
      icon: Icons.money_rounded,
      label: 'การเงิน',
    ),
    'EVENT': CategoryColor(
      color: Colors.amber,
      icon: Icons.event_rounded,
      label: 'กิจกรรม',
    ),
    'MAINTENANCE': CategoryColor(
      color: Colors.orange,
      icon: Icons.build_rounded,
      label: 'ซ่อมบำรุง',
    ),
  };

  static CategoryColor getCategory(String category) {
    return categoryMap[category] ?? categoryMap['GENERAL']!;
  }

  static Color getColor(String category) {
    return getCategory(category).color;
  }

  static IconData getIcon(String category) {
    return getCategory(category).icon;
  }

  static String getLabel(String category) {
    return getCategory(category).label;
  }

  // Get all categories for filter dropdown
  static List<String> getAllCategories() {
    return ['ALL', ...categoryMap.keys];
  }

  // Get category label for display in filter
  static String getCategoryLabel(String category) {
    if (category == 'ALL') return 'ทุกประเภท';
    return getLabel(category);
  }
}
