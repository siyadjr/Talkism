import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:talkism_user_app/core/routes/app_routes.dart';
import 'package:talkism_user_app/core/services/secure_storage_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = sl<AuthService>();
  final FirestoreService _firestoreService = sl<FirestoreService>();
  final SecureStorageService _secureStorage = sl<SecureStorageService>();
  final PresenceService _presenceService = sl<PresenceService>();

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
      _presenceService.startTracking(user.uid);
      _userModel = await _firestoreService.getUser(user.uid);
      if (_userModel != null) {
        await _firestoreService.setUserOnlineStatus(user.uid, true);
      }
    } else {
      _presenceService.stopTracking();
      if (_userModel != null) {
        await _firestoreService.setUserOnlineStatus(_userModel!.uid, false);
      }
      _userModel = null;
    }
    notifyListeners();
  }

  /// Unified Auth: If user exists, signs in. If not, creates account.
  Future<void> signInOrSignUp({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final trimmedEmail = email.trim();
      final trimmedPassword = password; // Passwords shouldn't be trimmed typically
      final trimmedName = name.trim();

      if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
        throw 'Email and password cannot be empty.';
      }

      // 1. Check if user exists in Firestore first
      final userExists = await _firestoreService.isUserExistsByEmail(trimmedEmail);
      User? user;

      if (userExists) {
        // 2. Sign In
        try {
          user = await _authService.signIn(trimmedEmail, trimmedPassword);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
            throw 'Incorrect password for this email account.';
          }
          rethrow;
        }
      } else {
        // 3. Sign Up
        try {
          user = await _authService.signUp(trimmedEmail, trimmedPassword);
          if (user != null) {
            // Create user profile in Firestore
            String? token;
            try {
              token = await FirebaseMessaging.instance.getToken();
            } catch (fcmError) {
              debugPrint("FCM Registration failed (Optional): $fcmError");
              // Continue without FCM token if it fails (common on emulators)
            }

            final newUser = UserModel(
              uid: user.uid,
              name: trimmedName,
              email: trimmedEmail,
              fcmToken: token,
              isOnline: true,
            );
            await _firestoreService.saveUser(newUser);
            _userModel = newUser;
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            // Special Case: Exists in Auth but not in Firestore - try to sign in
            try {
              user = await _authService.signIn(trimmedEmail, trimmedPassword);
            } on FirebaseAuthException catch (se) {
              if (se.code == 'invalid-credential' || se.code == 'wrong-password') {
                throw 'Incorrect password for this email account.';
              }
              rethrow;
            }
          } else {
            rethrow;
          }
        }
      }

      if (user != null) {
        _userModel ??= await _firestoreService.getUser(user.uid);
        await _firestoreService.setUserOnlineStatus(user.uid, true);
        await _secureStorage.login();

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      if (context.mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('] ')) {
          errorMessage = errorMessage.split('] ').last;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    if (_currentUser != null) {
      await _firestoreService.setUserOnlineStatus(_currentUser!.uid, false);
    }
    _presenceService.stopTracking();
    await _secureStorage.logout();
    await _authService.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.login,
      (route) => false,
    );
  }
}
