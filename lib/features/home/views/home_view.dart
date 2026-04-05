import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talkism_user_app/features/home/providers/home_provider.dart';
import 'package:talkism_user_app/features/auth/providers/auth_provider.dart';
import 'package:talkism_user_app/features/call/providers/call_provider.dart';
import 'package:talkism_user_app/core/constants/app_colors.dart';
import 'package:talkism_user_app/core/constants/app_text_styles.dart';
import 'package:talkism_user_app/core/models/call_model.dart';
import 'package:talkism_user_app/core/models/user_model.dart';
import 'package:talkism_user_app/core/routes/app_routes.dart';

import '../widgets/home_background_glow.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/user_list_tile.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/call_action_dialog.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().getUsers();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onCallUser(UserModel receiver, CallType type) {
    final caller = context.read<AuthProvider>().userModel;
    if (caller != null) {
      context.read<CallProvider>().startCall(caller, receiver, type, context);
      Navigator.pushNamed(context, Routes.call);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Caller info not found")));
    }
  }

  void _showCallDialog(UserModel receiver) {
    showDialog(
      context: context,
      builder: (_) => CallActionDialog(
        userName: receiver.name,
        onVoiceCall: () => _onCallUser(receiver, CallType.audio),
        onVideoCall: () => _onCallUser(receiver, CallType.video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const HomeBackgroundGlow(),
          RefreshIndicator(
            onRefresh: () => provider.getUsers(),
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 32),
                    const Text("Quick Actions", style: AppTextStyles.h2),
                    const SizedBox(height: 16),
                    _buildActionGrid(),
                    const SizedBox(height: 40),
                    const Text("Voice Contacts", style: AppTextStyles.h2),
                    const SizedBox(height: 16),
                    _buildUserList(provider),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }

  Widget _buildActionGrid() {
    return Row(
      children: [
        QuickActionCard(
          icon: Icons.videocam_rounded,
          title: "Video Call",
          color: AppColors.primary,
          onTap: () => _showActiveUsersDialog(CallType.video),
        ),
        const SizedBox(width: 16),
        QuickActionCard(
          icon: Icons.mic_none_outlined,
          title: "Audio Call",
          color: AppColors.accent,
          onTap: () => _showActiveUsersDialog(CallType.audio),
        ),
      ],
    );
  }

  void _showActiveUsersDialog(CallType type) {
    final homeProvider = context.read<HomeProvider>();
    final authProvider = context.read<AuthProvider>();
    final activeUsers = homeProvider.users.where((u) => u.isOnline && u.uid != authProvider.userModel?.uid).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Select Active ${type == CallType.video ? 'Expert' : 'Consultant'}",
          style: AppTextStyles.h2,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: activeUsers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No active users found at the moment.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyM,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: activeUsers.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final user = activeUsers[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      leading: CircleAvatar(
                        backgroundColor: (type == CallType.video ? AppColors.primary : AppColors.accent).withOpacity(0.1),
                        child: Icon(
                          type == CallType.video ? Icons.videocam : Icons.mic,
                          color: type == CallType.video ? AppColors.primary : AppColors.accent,
                          size: 20,
                        ),
                      ),
                      title: Text(user.name, style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text("Online Now", style: AppTextStyles.bodyM.copyWith(color: AppColors.success)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white30),
                      onTap: () {
                        Navigator.pop(context);
                        _onCallUser(user, type);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: AppTextStyles.bodyM.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(HomeProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.users.isEmpty) {
      return const Center(
        child: Text("No contacts found", style: AppTextStyles.bodyM),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = provider.users[index];
        return UserListTile(user: user, onTap: () => _showCallDialog(user));
      },
    );
  }
}
