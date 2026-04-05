import 'package:flutter/material.dart';
import '../providers/home_provider.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../core/models/user_model.dart';
import 'user_list_tile.dart';

class ExpertList extends StatelessWidget {
  final HomeProvider provider;
  final Function(UserModel) onUserTap;

  const ExpertList({
    required this.provider,
    required this.onUserTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.users.isEmpty) {
      return const Center(
        child: Text("No specialists available", style: AppTextStyles.bodyM),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = provider.users[index];
        return UserListTile(user: user, onTap: () => onUserTap(user));
      },
    );
  }
}
