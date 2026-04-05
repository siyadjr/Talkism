import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/models/user_model.dart';
import '../core/services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  User? _currentUser;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;
    if (user != null) {
      _userModel = await _firestoreService.getUser(user.uid);
      if (_userModel != null) {
        await _firestoreService.setUserOnlineStatus(user.uid, true);
      }
    } else {
      if (_userModel != null) {
        await _firestoreService.setUserOnlineStatus(_userModel!.uid, false);
      }
      _userModel = null;
    }
    notifyListeners();
  }

  Future<bool> signUp(String email, String password, String name,BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.signUp(email, password);
      if (user != null) {
        final newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          isOnline: true,
        );
        await _firestoreService.saveUser(newUser);
        _userModel = newUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        _userModel = await _firestoreService.getUser(user.uid);
        await _firestoreService.setUserOnlineStatus(user.uid, true);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    if (_currentUser != null) {
      await _firestoreService.setUserOnlineStatus(_currentUser!.uid, false);
    }
    await _authService.signOut();
  }
}
