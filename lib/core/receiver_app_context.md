# Talkism Receiver App Context

This document provides the foundational context, architecture, and logic requirements for the **Talkism Receiver App**. This app is designed to work in tandem with the **Talkism User App** to provide real-time audio and video calling using Firebase and Agora.

## 1. Project Architecture (Modular & Feature-Based)
The application follows a clean, modular structure where state management and UI are coupled by feature rather than centralized.

- **`lib/features/`**: Each folder (e.g., `auth`, `call`, `home`, `splash`) contains its own:
    - `providers/`: State management (ChangeNotifier).
    - `views/`: UI Screens.
    - `widgets/`: Feature-specific sub-widgets (extracted from build methods).
- **`lib/core/`**: Shared components:
    - `models/`: Data classes (`UserModel`, `CallModel`).
    - `services/`: Global services (Firebase, Agora).
    - `services/service_locator.dart` (using **GetIt** with the variable name **`sl`**).

## 2. Core Dependencies
- **Firebase**: `firebase_auth`, `cloud_firestore`, `firebase_messaging`.
- **Media**: `agora_rtc_engine`, `permission_handler`.
- **State Management**: `provider`.
- **Dependency Injection**: `get_it`.
- **Storage**: `flutter_secure_storage`.

## 3. Firestore Collection Strategy
The app shares the same Firebase project as the **User App**, but uses a specific collection for its own users:

| Feature | User App | Receiver App | Shared |
| :--- | :--- | :--- | :--- |
| **Profile Storage** | `users` collection | `receivers` collection | **No** |
| **Call Signaling** | Reads/Writes to `calls` | Reads/Writes to `calls` | **Yes** |
| **UserModel structure**| Same structure | Same structure | **Yes** |

### Shared UserModel Structure:
```dart
{
  "uid": String,
  "name": String,
  "email": String,
  "fcmToken": String?,
  "isOnline": bool
}
```

## 4. Call Signaling Logic
Signaling is handled via the **`calls`** collection.

1.  **User App** creates a document in `calls` with `docId = channelId`.
2.  **Receiver App** listens to the `calls` collection where `receiverId == itsUid` and `status == "ringing"`.
3.  **Receiver App** accepts or rejects by updating the `status` field in the same document.
4.  **Agora Media**: Both apps join the same **`channelId`** as the room name using the **Agora App ID** (provided in `AgoraService`).

## 5. Industrial Standards
- **No `_build` Methods**: All UI components must be extracted into standalone widgets in the `widgets/` folder of each feature.
- **Service Locator**: All services (Auth, Firestore, Agora) MUST be accessed via `sl<Type>()`.
- **Presence**: Both apps use a `PresenceService` to update `isOnline` in their respective collections based on the `WidgetsBindingObserver` lifecycle.
- **Provider Access**: Use `context.watch<T>()` for reactivity and `initState` with `addPostFrameCallback` for data initialization.

## 6. Shared Agora App ID
**App ID**: `30d685fc0f0e41e2a7271b7bdc807606`
**Token Logic**: Currently using an empty string (`""`) for testing mode (App Certificate not enforced). 
