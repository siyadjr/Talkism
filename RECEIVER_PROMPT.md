# Antigravity Prompt: Talkism Receiver App

This document is designed to be provided to **Antigravity** (AI Coding Assistant) when initializing or working on the **Talkism Receiver App**. It provides the necessary context, technical requirements, and aesthetic guidelines to ensure consistency with the Talkism ecosystem.

---

## 🚀 Project Overview
**Project Name:** Talkism Receiver App  
**Mission:** The "expert/receiver" side of the Talkism platform, designed to handle incoming video/audio calls from the Talkism User App, manage availability, and provide a premium interface for professional interactions.

### 🔗 Relationship to User App
- **User App:** Initiates calls, browses experts, and pays for consultations.
- **Receiver App:** Receives real-time notifications for calls, tracks earnings, and manages status (online/offline).

---

## 🛠️ Tech Stack (Mandatory)
- **Framework:** Flutter
- **State Management:** Provider (consistent with User App)
- **Backend:** Firebase (Firestore, Auth, Cloud Messaging)
- **Video/Audio Engine:** Agora RTC SDK
- **Call Management:** `flutter_callkit_incoming` (for high-priority call screens)
- **Architecture:** Clean Architecture with separate Layers (Core, Features, Providers, Services).

---

## 🎨 Design Aesthetics & UX
**Theme:** Sleek, Premium Dark Mode (following `AppTheme.darkTheme` from User App)
- **Colors:** Deep midnights, vibrant cobalt accents, and subtle gold/secondary highlights.
- **Visuals:** 
    - Use gradients for buttons and calling screens.
    - Glassmorphism effects for cards and overlays.
    - Smooth micro-animations for incoming call alerts.
    - High-quality icons (Cupertino or custom).
- **Typography:** Modern, clean sans-serif (e.g., Inter or Outfit).

---

## 📦 Core Features to Implement
1.  **Firebase Auth:** Sign-in for experts/receivers.
2.  **Expert Profile/Status:** Update online/offline availability in Firestore.
3.  **Incoming Call Handling:**
    - Integration with `flutter_callkit_incoming` to wake up the app.
    - Real-time Firestore listeners for incoming call requests.
    - Agora integration to join the channel matching the caller ID.
4.  **In-Call Dashboard:**
    - High-quality video preview.
    - Toggle Audio/Video, Switch Camera.
    - Call duration tracking.
5.  **History & Earnings:** A clean dashboard showing past sessions and revenue.

---

## 💡 Prompt for Antigravity (Copy-Paste this)

> "Antigravity, I am working on the **Talkism Receiver App**. 
> 
> My goal is to build a high-performance, premium Flutter application that integrates with Firebase and Agora to receive calls from the Talkism User App. 
>
> Please help me implement/refine the following:
> 1.  Ensure the tech stack uses Flutter, Provider, Firebase, and Agora RTC.
> 2.  Maintain a high-end dark theme with glassmorphism and subtle animations.
> 3.  Implement the Incoming Call logic using `flutter_callkit_incoming` and Firestore listeners.
> 4.  Keep the code modular and consistent with the User App's architecture.
>
> Let's start by [ACTION - e.g., setting up the CallProvider or designing the Incoming Call screen]."

---

## 📁 Repository Structure Reference
```text
lib/
├── core/         # Global themes, routes, constants, widgets
├── features/     # Feature-based logic (auth, call, profile)
├── services/     # Firebase, Agora, Notifications
├── providers/    # State management
└── main.dart     # Entry point
```
