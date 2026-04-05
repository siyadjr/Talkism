import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talkism_user_app/core/routes/app_routes.dart';
import 'package:talkism_user_app/core/services/secure_storage_service.dart';
import 'package:talkism_user_app/core/services/service_locator.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

final secureStorage=sl<SecureStorageService>();
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;
    log("Initializing splash");

    // 1. Notification Permission
    await _requestNotificationPermission();

    // 2. Short Delay for Splash visual
    await Future.delayed(const Duration(seconds: 2));

    // 3. Navigation Logic (based on Auth)
    if (context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = await secureStorage.isLoggedIn();
      
      if (isLoggedIn && authProvider.currentUser != null) {
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
      // If denied, we can try permission_handler for a more direct prompt if needed
      await Permission.notification.request();
    }
  }
}
