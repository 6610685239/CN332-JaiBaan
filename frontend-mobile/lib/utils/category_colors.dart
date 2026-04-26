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
      color: const Color(0xFFE53935),
      icon: Icons.error_rounded,
      label: 'ด่วน',
    ),
    'GENERAL': CategoryColor(
      color: const Color(0xFF1E88E5),
      icon: Icons.campaign_rounded,
      label: 'ข่าวสาร',
    ),
    'FINANCE': CategoryColor(
      color: const Color(0xFF43A047),
      icon: Icons.account_balance_wallet_rounded,
      label: 'การเงิน',
    ),
    'EVENT': CategoryColor(
      color: const Color(0xFFFB8C00),
      icon: Icons.celebration_rounded,
      label: 'กิจกรรม',
    ),
    'MAINTENANCE': CategoryColor(
      color: const Color(0xFF8E24AA),
      icon: Icons.home_repair_service_rounded,
      label: 'ซ่อมบำรุง',
    ),
  };

  static CategoryColor getCategory(String category) {
    return categoryMap[category] ?? categoryMap['GENERAL']!;
  }

  static Color getColor(String category) => getCategory(category).color;
  static IconData getIcon(String category) => getCategory(category).icon;
  static String getLabel(String category) => getCategory(category).label;

  static List<String> getAllCategories() => ['ALL', ...categoryMap.keys];

  static String getCategoryLabel(String category) {
    if (category == 'ALL') return 'ทุกประเภท';
    return getLabel(category);
  }
}
