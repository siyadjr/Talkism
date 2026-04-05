import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.6),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomNavItem(Icons.grid_view_rounded, true),
              _bottomNavItem(Icons.history_rounded, false),
              _bottomNavItem(Icons.settings_rounded, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, bool active) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: active ? AppColors.primary : AppColors.textSecondary,
        size: 28,
      ),
    );
  }
}
