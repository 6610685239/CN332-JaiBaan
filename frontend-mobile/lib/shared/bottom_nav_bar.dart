// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';

class JaiBaanBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const JaiBaanBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  static const _activeColor = Color(0xFFFF7043);
  static const _inactiveColor = Color(0xFFBDBDBD);

  static const _items = [
    _NavItem(icon: Icons.home_rounded,         label: 'Home'),
    _NavItem(icon: Icons.calendar_month_rounded, label: 'Facilities'),
    _NavItem(icon: Icons.phone_rounded,         label: 'Call Juristic'),
    _NavItem(icon: Icons.settings_rounded,      label: 'Setting'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashColor: _activeColor.withOpacity(0.08),
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 24,
                        color: isActive ? _activeColor : _inactiveColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? _activeColor : _inactiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
