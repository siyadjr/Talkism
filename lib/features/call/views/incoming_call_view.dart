import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:provider/provider.dart';
import '../providers/call_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/call_model.dart';
import '../../../core/routes/app_routes.dart';

class IncomingCallView extends StatefulWidget {
  const IncomingCallView({super.key});

  @override
  State<IncomingCallView> createState() => _IncomingCallViewState();
}

class _IncomingCallViewState extends State<IncomingCallView> {
  VideoViewController? _localController;

  void _initLocalController(RtcEngine engine) {
    if (_localController != null) return;
    _localController = VideoViewController(
      rtcEngine: engine,
      canvas: const VideoCanvas(uid: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);

    // If call was accepted, navigate to active call screen
    if (callProvider.isJoined) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
          context,
          Routes.call
        );
      });
    }

    if (callProvider.isEngineInitialized) {
      _initLocalController(callProvider.engine!);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.darkGradient,
            ),
          ),

          // Main UI Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              
              // 🎥 Local Video Preview or Caller Avatar
              Center(
                child: Container(
                  width: 160,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: AppColors.surface.withOpacity(0.3),
                    border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        if (callProvider.currentCall?.type == CallType.video && 
                            callProvider.isVideoEnabled && 
                            _localController != null)
                          AgoraVideoView(controller: _localController!)
                        else if (callProvider.currentCall?.type == CallType.audio)
                          const Center(
                            child: Icon(Icons.person, color: AppColors.primary, size: 80),
                          )
                        else
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: Icon(Icons.videocam_off, color: Colors.white24, size: 40),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              const Text(
                'INCOMING CALL',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                callProvider.currentCall?.callerName ?? 'Talkism User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Consultation Session',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              
              const Spacer(),

              // 🎛️ Pre-Accept Controls (Mute/Video Off)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSmallControl(
                    icon: callProvider.isMicEnabled ? Icons.mic : Icons.mic_off,
                    onTap: () => callProvider.toggleMic(),
                    isActive: callProvider.isMicEnabled,
                  ),
                  if (callProvider.currentCall?.type == CallType.video) ...[
                    const SizedBox(width: 24),
                    _buildSmallControl(
                      icon: callProvider.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                      onTap: () => callProvider.toggleVideo(),
                      isActive: callProvider.isVideoEnabled,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 48),

              // 📞 Action Buttons (Accept/Decline)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCallButton(
                      icon: Icons.close,
                      color: AppColors.error,
                      label: 'Decline',
                      onTap: () => callProvider.declineCall(context: context),
                    ),
                    _buildCallButton(
                      icon: Icons.check,
                      color: AppColors.success,
                      label: 'Accept',
                      isGlow: true,
                      onTap: () => callProvider.acceptCall(context: context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallControl({
    required IconData icon,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.white10 : AppColors.error.withOpacity(0.2),
          border: Border.all(color: isActive ? Colors.white24 : AppColors.error),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    bool isGlow = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: isGlow
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
