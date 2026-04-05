# Talkism - Audio & Video Calling Apps

This project consists of two Flutter applications:
1. **User App (Caller)**: For initiating audio and video calls.
2. **Receiver App (Receiver)**: For receiving and handling incoming calls.

## Setup Steps

### 1. Firebase Setup
1. Create a Firebase Project.
2. Register both apps (`talkism.user.app` and `talkism.receiver.app`).
3. Enable **Email/Password Authentication**.
4. Create a **Firestore Database** (start in test mode).
5. Enable **Firebase Cloud Messaging (FCM)** for notifications.
6. Download `google-services.json` for Android and `GoogleService-Info.plist` for iOS.
7. Place them in the respective `android/app/` and `ios/Runner/` folders of both projects.

### 2. Agora Setup
1. Create an account on [Agora.io](https://www.agora.io/).
2. Create a new Project and get the **App ID**.
3. Update the `appId` in `lib/services/agora_service.dart` in both apps.

### 3. Webhook / Cloud Functions (Optional but Recommended)
The apps use a Webhook service for call lifecycle events. You can deploy a Firebase Cloud Function for this:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.callEvents = functions.https.onRequest(async (req, res) => {
  const { eventType, call } = req.body;
  
  if (eventType === 'create') {
    // Send FCM notification to receiver
    const receiverToken = await getReceiverToken(call.receiverId);
    if (receiverToken) {
      await admin.messaging().send({
        token: receiverToken,
        notification: {
          title: "Incoming Call",
          body: `Incoming ${call.type} call from ${call.callerName}`,
        },
        data: {
          channelId: call.channelId,
          callerName: call.callerName,
          type: call.type,
        }
      });
    }
  }
  
  res.status(200).send("Event processed");
});
```

## Running the Apps
1. Open each project in a separate terminal.
2. Run `flutter pub get`.
3. Run `flutter run`.

## Notes
- State management uses **Provider**.
- Signaling is handled via **Firestore**.
- Real-time communication uses **Agora RTC**.
