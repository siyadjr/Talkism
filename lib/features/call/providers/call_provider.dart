import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/call_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/routes/app_routes.dart';

class CallProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = sl<FirestoreService>();
  final AgoraService _agoraService = sl<AgoraService>();
  // final WebhookService _webhookService = sl<WebhookService>();

  CallModel? _currentCall;
  CallModel? get currentCall => _currentCall;

  int? _remoteUid;
  int? get remoteUid => _remoteUid;

  int _duration = 0;
  int get duration => _duration;
  Timer? _timer;

  bool _isMuted = false;
  bool _isVideoDisabled = false;
  bool _isJoined = false;
  bool _isRemoteVideoEnabled = true;

  bool get isMuted => _isMuted;
  bool get isVideoDisabled => _isVideoDisabled;
  bool get isMicEnabled => !_isMuted;
  bool get isVideoEnabled => !_isVideoDisabled;
  bool get isJoined => _isJoined;
  bool get isRemoteVideoEnabled => _isRemoteVideoEnabled;
  bool get isEngineInitialized => _agoraService.engine != null;
  String? get activeCallId => _currentCall?.channelId;

  StreamSubscription? _callSubscription;
  StreamSubscription? _incomingCallSubscription;

  Future<void> startCall(
    UserModel caller,
    UserModel receiver,
    CallType type,
    BuildContext context,
  ) async {
    // Channel ID must be less than 64 bytes
    final channelId =
        'c_${caller.uid.substring(0, 5)}_${DateTime.now().millisecondsSinceEpoch}';
    final call = CallModel(
      callerId: caller.uid,
      callerName: caller.name,
      receiverId: receiver.uid,
      receiverName: receiver.name,
      channelId: channelId,
      status: CallStatus.ringing,
      type: type,
      timestamp: DateTime.now(),
    );

    _currentCall = call;

    // Set initial toggle states based on call type
    _isVideoDisabled = type == CallType.audio;
    _isMuted = false;

    await _firestoreService.saveCall(call);
    // await _webhookService.triggerCallEvent('create', call);

    // Setup signaling listener
    _listenToSignaling(channelId, context);

    // Join Agora channel
    await _agoraService.initialize();
    _setupAgoraEvents();

    // Apply initial settings
    await _agoraService.toggleVideo(!_isVideoDisabled);
    await _agoraService.toggleMute(_isMuted);

    await _agoraService.joinChannel(
      channelId,
      caller.uid.hashCode,
      publishVideo: type == CallType.video,
    );

    _isJoined = true;
    notifyListeners();
  }

  Future<void> acceptCall({CallModel? call, BuildContext? context}) async {
    final callToAccept = call ?? _currentCall;
    if (callToAccept == null) return;

    _currentCall = callToAccept;

    // Set initial toggle states based on call type from the incoming call model
    _isVideoDisabled = callToAccept.type == CallType.audio;
    _isMuted = false;

    await _firestoreService.updateCallStatus(
      callToAccept.channelId,
      CallStatus.connected,
    );
    // await _webhookService.triggerCallEvent(
    //   'update',
    //   callToAccept.copyWithStatus(CallStatus.connected),
    // );

    if (context != null) {
      _listenToSignaling(callToAccept.channelId, context);
    }

    await _agoraService.initialize();
    _setupAgoraEvents();

    // Apply initial settings
    await _agoraService.toggleVideo(!_isVideoDisabled);
    await _agoraService.toggleMute(_isMuted);

    await _agoraService.joinChannel(
      callToAccept.channelId,
      callToAccept.receiverId.hashCode,
      publishVideo: callToAccept.type == CallType.video,
    );

    _isJoined = true;
    _startTimer();
    notifyListeners();
  }

  void _setupAgoraEvents() {
    _agoraService.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (connection, remoteUid, elapsed) {
          _remoteUid = remoteUid;
          _startTimer();
          notifyListeners();
        },
        onUserOffline: (connection, remoteUid, reason) {
          _remoteUid = null;
          notifyListeners();
          endCall();
        },
        onRemoteVideoStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
              if (remoteUid == _remoteUid) {
                _isRemoteVideoEnabled =
                    state == RemoteVideoState.remoteVideoStateDecoding;
                notifyListeners();
              }
            },
      ),
    );
  }

  void _listenToSignaling(String channelId, BuildContext context) {
    _callSubscription?.cancel();
    _callSubscription = _firestoreService.listenToCall(channelId).listen((
      call,
    ) {
      if (call == null) return;
      _currentCall = call;
      if (call.status == CallStatus.ended ||
          call.status == CallStatus.rejected ||
          call.status == CallStatus.declined) {
        _cleanupCall(context);
      }
      notifyListeners();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _duration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> endCall({BuildContext? context}) async {
    final call = _currentCall;
    if (call != null) {
      await _firestoreService.updateCallStatus(
        call.channelId,
        CallStatus.ended,
      );
      // await _webhookService.triggerCallEvent('end', call);
      _cleanupCall(context);
    }
  }

  void _cleanupCall(BuildContext? context) async {
    if (_currentCall == null) return;

    final status = _currentCall?.status;
    _stopTimer();
    _callSubscription?.cancel();
    _remoteUid = null;
    
    // Release Agora resources immediately
    await _agoraService.leaveChannel();
    _isJoined = false;

    // Small delay and show snackbar to the user before popping
    if (context != null && context.mounted && (status == CallStatus.ended || status == CallStatus.declined || status == CallStatus.rejected)) {
      final message = status == CallStatus.ended ? 'Call Ended' : 'Call Declined';
      final statusColor = status == CallStatus.ended ? Colors.white : AppColors.error;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message, 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          backgroundColor: Colors.grey[900]?.withOpacity(0.95),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      
      notifyListeners(); // Refresh UI to show status text on screen too
      await Future.delayed(const Duration(seconds: 2));
    }

    _currentCall = null;

    if (context != null && context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
    }
    notifyListeners();
  }

  Future<void> declineCall({CallModel? call, BuildContext? context}) async {
    final callToDecline = call ?? _currentCall;
    if (callToDecline == null) return;

    await _firestoreService.updateCallStatus(
      callToDecline.channelId,
      CallStatus.rejected,
    );
    // await _webhookService.triggerCallEvent('update', callToDecline);
    _cleanupCall(context);
  }

  void toggleMic() {
    _isMuted = !_isMuted;
    _agoraService.toggleMute(_isMuted);
    notifyListeners();
  }

  void toggleVideo() {
    _isVideoDisabled = !_isVideoDisabled;
    _agoraService.toggleVideo(!_isVideoDisabled);
    notifyListeners();
  }

  RtcEngine? get engine => _agoraService.engine;

  void switchCamera() {
    _agoraService.switchCamera();
  }

  void stopListeningToIncomingCalls() {
    _incomingCallSubscription?.cancel();
    _incomingCallSubscription = null;
  }
}

extension CallModelExtension on CallModel {
  CallModel copyWithStatus(CallStatus status) {
    return CallModel(
      callerId: callerId,
      callerName: callerName,
      receiverId: receiverId,
      receiverName: receiverName,
      channelId: channelId,
      status: status,
      type: type,
      timestamp: timestamp,
    );
  }
}
