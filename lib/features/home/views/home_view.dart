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
import '../widgets/home_bottom_nav.dart';
import '../widgets/call_action_dialog.dart';
import '../widgets/home_action_grid.dart';
import '../widgets/expert_list.dart';

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
      builder: (context) => CallActionDialog(
        userName: receiver.name,
        onVoiceCall: () => _onCallUser(receiver, CallType.audio),
        onVideoCall: () => _onCallUser(receiver, CallType.video),
      ),
    );
  }

  void _showActiveUsersDialog(CallType type) {
    final homeProvider = context.read<HomeProvider>();
    final authProvider = context.read<AuthProvider>();
    final activeUsers = homeProvider.users
        .where((u) => u.isOnline && u.uid != authProvider.userModel?.uid)
        .toList();

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
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final user = activeUsers[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            (type == CallType.video
                                    ? AppColors.primary
                                    : AppColors.accent)
                                .withOpacity(0.1),
                        child: Icon(
                          type == CallType.video ? Icons.videocam : Icons.mic,
                          color: type == CallType.video
                              ? AppColors.primary
                              : AppColors.accent,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: AppTextStyles.bodyL.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "Online Now",
                        style: AppTextStyles.bodyM.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.white30,
                      ),
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
            child: Text(
              "Cancel",
              style: AppTextStyles.bodyM.copyWith(color: AppColors.error),
            ),
          ),
        ],
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
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 32),
                    const Text("Quick Actions", style: AppTextStyles.h2),
                    const SizedBox(height: 16),
                    HomeActionGrid(onActionTap: _showActiveUsersDialog),
                    const SizedBox(height: 40),
                    const Text("Specialists Near You", style: AppTextStyles.h2),
                    const SizedBox(height: 16),
                    ExpertList(provider: provider, onUserTap: _showCallDialog),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
