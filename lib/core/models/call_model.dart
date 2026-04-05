enum CallStatus { ringing, connected, ongoing, ended, rejected, declined }
enum CallType { audio, video }

class CallModel {
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final String channelId;
  final CallStatus status;
  final CallType type;
  final DateTime timestamp;

  CallModel({
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.channelId,
    required this.status,
    required this.type,
    required this.timestamp,
  });

  factory CallModel.fromMap(Map<String, dynamic> data) {
    DateTime parseTimestamp(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.parse(val);
      try {
        return (val as dynamic).toDate(); // Firestore Timestamp
      } catch (_) {
        return DateTime.now();
      }
    }

    return CallModel(
      callerId: data['callerId'] ?? '',
      callerName: data['callerName'] ?? '',
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'] ?? '',
      channelId: data['channelId'] ?? '',
      status: CallStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'ringing'),
        orElse: () => CallStatus.ringing,
      ),
      type: CallType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'audio'),
        orElse: () => CallType.audio,
      ),
      timestamp: parseTimestamp(data['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'channelId': channelId,
      'status': status.name,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
