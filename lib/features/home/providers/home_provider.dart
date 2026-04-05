import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:talkism_user_app/core/models/user_model.dart';
import 'package:talkism_user_app/core/services/firestore_service.dart';
import 'package:talkism_user_app/core/services/service_locator.dart';

class HomeProvider extends ChangeNotifier {
  bool isLoading = false;
  List<UserModel> _users = [];
  List<UserModel> get users => _users;
  final FirestoreService _firestoreService = sl<FirestoreService>();
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> getUsers() async {
    log('Calledget users>>>>>>>>>>>');
    setLoading(true);
    try {
      final users = await _firestoreService.fetchUsers();
      _users = users.toList();
    } catch (e) {
      debugPrint(e.toString());
    }
    setLoading(false);
  }
}
