import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/call_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/call_model.dart';

class ActiveCallView extends StatefulWidget {
  const ActiveCallView({super.key});

  @override
  State<ActiveCallView> createState() => _ActiveCallViewState();
}

class _ActiveCallViewState extends State<ActiveCallView> {
  VideoViewController? _localController;
  VideoViewController? _remoteController;
  int? _remoteUid;

  @override
  void dispose() {
    // Controllers belong to the view, but the engine is managed by the provider
    // We don't necessarily need to dispose the engine here, but the view is gone
    super.dispose();
  }

  void _initLocalController(RtcEngine engine) {
    if (_localController != null) return;
    _localController = VideoViewController(
      rtcEngine: engine,
      canvas: const VideoCanvas(uid: 0),
    );
  }

  void _initRemoteController(
    RtcEngine engine,
    String channelId,
    int remoteUid,
  ) {
    if (_remoteController != null && _remoteUid == remoteUid) return;
    _remoteUid = remoteUid;
    _remoteController = VideoViewController.remote(
      rtcEngine: engine,
      canvas: VideoCanvas(uid: remoteUid),
      connection: RtcConnection(channelId: channelId),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);

    // Initialize/Update controllers only when necessary
    if (callProvider.isEngineInitialized) {
      _initLocalController(callProvider.engine!);
      if (callProvider.remoteUid != null && callProvider.activeCallId != null) {
        _initRemoteController(
          callProvider.engine!,
          callProvider.activeCallId!,
          callProvider.remoteUid!,
        );
      } else {
        _remoteController = null;
        _remoteUid = null;
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Content: Remote Video or Audio/Video-Off Profile
          Center(
            child:
                _remoteController != null &&
                    callProvider.currentCall?.type == CallType.video &&
                    callProvider.isRemoteVideoEnabled
                ? AgoraVideoView(controller: _remoteController!)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (callProvider.remoteUid != null)
                        _buildVideoOffPlaceholder(
                          callProvider.currentCall?.receiverName ?? 'Expert',
                          isRemote: true,
                          isAudioOnly:
                              callProvider.currentCall?.type == CallType.audio,
                        )
                      else ...[
                        const CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Waiting for user to join...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),

          // Header: Timer and Status
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (callProvider.activeCallId != null)
                  Text(
                    'Room: ${callProvider.activeCallId}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDuration(callProvider.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  callProvider.currentCall?.status.name.toUpperCase() ?? 'CONNECTING',
                  style: TextStyle(
                    color: callProvider.remoteUid != null || callProvider.currentCall?.status == CallStatus.connected
                        ? AppColors.success
                        : (callProvider.currentCall?.status == CallStatus.declined || callProvider.currentCall?.status == CallStatus.ended)
                          ? AppColors.error
                          : Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Local Preview (Top Right) - Always visible if initialized
          if (_localController != null &&
              callProvider.currentCall?.type == CallType.video)
            Positioned(
              top: 80,
              right: 20,
              child: Container(
                width: 110,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black45,
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: callProvider.isVideoEnabled
                      ? AgoraVideoView(controller: _localController!)
                      : Container(
                          color: Colors.black87,
                          child: const Center(
                            child: Icon(
                              Icons.videocam_off,
                              color: Colors.white24,
                              size: 30,
                            ),
                          ),
                        ),
                ),
              ),
            ),

          // Controls (Bottom)
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: callProvider.isMicEnabled ? Icons.mic : Icons.mic_off,
                    color: callProvider.isMicEnabled
                        ? Colors.white24
                        : AppColors.error,
                    onTap: () => callProvider.toggleMic(),
                  ),
                  _buildControlButton(
                    icon: Icons.call_end,
                    color: AppColors.error,
                    isLarge: true,
                    onTap: () async {
                      await callProvider.endCall();
                      // if (context.mounted) Navigator.pop(context);
                    },
                  ),
                  if (callProvider.currentCall?.type == CallType.video)
                    _buildControlButton(
                      icon: callProvider.isVideoEnabled
                          ? Icons.videocam
                          : Icons.videocam_off,
                      color: callProvider.isVideoEnabled
                          ? Colors.white24
                          : AppColors.error,
                      onTap: () => callProvider.toggleVideo(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoOffPlaceholder(
    String name, {
    bool isRemote = true,
    bool isAudioOnly = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isAudioOnly ? Icons.mic : Icons.videocam_off,
              color: AppColors.primary,
              size: 70,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isAudioOnly ? 'Voice Call Ongoing' : 'Camera is Off',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 20 : 15),
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Icon(icon, color: Colors.white, size: isLarge ? 32 : 24),
      ),
    );
  }
}
