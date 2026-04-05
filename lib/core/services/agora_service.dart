import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static const String appId = "5c57e37ba34947a6aea7b0376841d8d4";
  RtcEngine? _engine;

  Future<void> initialize() async {
    if (_engine != null) return; // Prevent multiple initializations

    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await _engine!.enableVideo();
    await _engine!.startPreview();
  }

  void registerEventHandler(RtcEngineEventHandler handler) {
    _engine?.registerEventHandler(handler);
  }

  Future<void> joinChannel(String channelId, int uid, {String token = "", bool publishVideo = true}) async {
    if (_engine == null) return;
    
    // Ensure UID is positive (some platforms use negative hashcodes)
    final positiveUid = uid.abs();

    await _engine!.joinChannel(
      token: token,
      channelId: channelId,
      uid: positiveUid,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: publishVideo,
        publishMicrophoneTrack: true,
      ),
    );
  }

  Future<void> leaveChannel() async {
    if (_engine == null) return;
    await _engine!.leaveChannel();
    await _engine!.stopPreview();
    await _engine!.release();
    _engine = null;
  }

  Future<void> toggleMute(bool isMuted) async {
    if (_engine == null) return;
    await _engine!.muteLocalAudioStream(isMuted);
  }

  Future<void> toggleVideo(bool enable) async {
    if (_engine == null) return;
    await _engine!.enableLocalVideo(enable);
  }

  Future<void> switchCamera() async {
    if (_engine == null) return;
    await _engine!.switchCamera();
  }

  RtcEngine? get engine => _engine;
}
