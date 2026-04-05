import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'service_locator.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = sl<FirestoreService>();

  Future<void> initialize(String uid) async {
    try {
      // Request permission
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get token
        String? token = await _fcm.getToken();
        if (token != null) {
          await _firestoreService.updateFcmToken(uid, token);
        }
      }
    } catch (e) {
      debugPrint("Notification service initialization failed: $e");
      // Allow initialization to fail silently so as not to break other app flows
    }

    // Listen for messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message: ${message.data}");
      // Handle incoming call notification here
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Message opened app: ${message.data}");
    });
  }

  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    debugPrint("Background message: ${message.data}");
    // Handle background incoming call notification
  }
}
