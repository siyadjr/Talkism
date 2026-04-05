import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:talkism_user_app/core/services/secure_storage_service.dart';
import 'package:talkism_user_app/core/services/auth_service.dart';
import 'package:talkism_user_app/core/services/firestore_service.dart';
import 'package:talkism_user_app/core/services/agora_service.dart';
import 'package:talkism_user_app/core/services/webhook_service.dart';
import 'package:talkism_user_app/core/services/notification_service.dart';
import 'package:talkism_user_app/core/services/presence_service.dart';

export 'package:talkism_user_app/core/services/auth_service.dart';
export 'package:talkism_user_app/core/services/firestore_service.dart';
export 'package:talkism_user_app/core/services/agora_service.dart';
export 'package:talkism_user_app/core/services/webhook_service.dart';
export 'package:talkism_user_app/core/services/notification_service.dart';
export 'package:talkism_user_app/core/services/secure_storage_service.dart';
export 'package:talkism_user_app/core/services/presence_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  // Services
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<FirestoreService>(() => FirestoreService());
  sl.registerLazySingleton<AgoraService>(() => AgoraService());
  // sl.registerLazySingleton<WebhookService>(() => WebhookService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<PresenceService>(() => PresenceService());
}
