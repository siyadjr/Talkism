import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/call_model.dart';
import 'quick_action_card.dart';

class HomeActionGrid extends StatelessWidget {
  final Function(CallType) onActionTap;

  const HomeActionGrid({
    required this.onActionTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        QuickActionCard(
          icon: Icons.videocam_rounded,
          title: "Video Call",
          color: AppColors.primary,
          onTap: () => onActionTap(CallType.video),
        ),
        const SizedBox(width: 16),
        QuickActionCard(
          icon: Icons.mic_none_outlined,
          title: "Audio Call",
          color: AppColors.accent,
          onTap: () => onActionTap(CallType.audio),
        ),
      ],
    );
  }
}
