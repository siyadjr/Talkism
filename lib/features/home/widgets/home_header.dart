import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talkism_user_app/features/auth/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Talkism", style: AppTextStyles.h1),
            Text(
              "Ready for your next call?",
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.primary.withOpacity(0.8),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
            onTap: () => _showLogoutDialog(context),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.background,
              child: Icon(Icons.logout, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Sign Out", style: AppTextStyles.h2),
        content: const Text(
          "Are you sure you want to log out of Talkism?",
          style: AppTextStyles.bodyM,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: AppTextStyles.button.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut(context);
            },
            child: Text(
              "Logout",
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
