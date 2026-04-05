import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/call_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<bool> isUserExistsByEmail(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<List<UserModel>> fetchUsers() async {
    final users = await _firestore.collection('receivers').get();

    log('users is ${users.docs.map((doc) => UserModel.fromMap(doc.data())).toList()}');
    return users.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  Future<void> setUserOnlineStatus(String uid, bool isOnline) async {
    await _firestore.collection('users').doc(uid).set({
      'isOnline': isOnline,
    }, SetOptions(merge: true));
  }

  Future<void> saveCall(CallModel call) async {
    await _firestore.collection('calls').doc(call.channelId).set(call.toMap());
  }

  Future<void> updateCallStatus(String channelId, CallStatus status) async {
    await _firestore.collection('calls').doc(channelId).set({
      'status': status.name,
    }, SetOptions(merge: true));
  }

  Stream<CallModel?> getLatestCall(String uid) {
    return _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: uid)
        .where('status', isEqualTo: CallStatus.ringing.name)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return CallModel.fromMap(snapshot.docs.first.data());
          }
          return null;
        });
  }

  Stream<CallModel?> listenToCall(String channelId) {
    return _firestore
        .collection('calls')
        .doc(channelId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return CallModel.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  Future<void> updateFcmToken(String uid, String? token) async {
    await _firestore.collection('users').doc(uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }
}
