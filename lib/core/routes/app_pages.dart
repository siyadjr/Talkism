import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/call/views/active_call_view.dart';

class AppPages {
  static const initial = Routes.splash;

  static Map<String, WidgetBuilder> get routes => {
    Routes.splash: (context) => const SplashView(),
    Routes.login: (context) => const LoginView(),
    Routes.home: (context) => const HomeView(),
    Routes.call: (context) => const ActiveCallView(),
  };
}