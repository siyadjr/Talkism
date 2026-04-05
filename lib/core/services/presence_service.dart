import 'package:flutter/material.dart';
import 'package:talkism_user_app/core/services/service_locator.dart';

class PresenceService with WidgetsBindingObserver {
  String? _uid;
  final FirestoreService _firestoreService = sl<FirestoreService>();

  void startTracking(String uid) {
    _uid = uid;
    WidgetsBinding.instance.addObserver(this);
    _setUserStatus(true);
  }

  void stopTracking() {
    if (_uid != null) {
      _setUserStatus(false);
    }
    WidgetsBinding.instance.removeObserver(this);
    _uid = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_uid == null) return;

    if (state == AppLifecycleState.resumed) {
      _setUserStatus(true);
    } else {
      _setUserStatus(false);
    }
  }

  Future<void> _setUserStatus(bool isOnline) async {
    if (_uid != null) {
      await _firestoreService.setUserOnlineStatus(_uid!, isOnline);
    }
  }
}
