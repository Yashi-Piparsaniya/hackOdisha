import 'package:flutter/material.dart';

import '../app/auth/screens/chat.dart';
import '../app/auth/screens/history.dart';
import '../app/auth/screens/home_screen.dart';
import '../app/auth/screens/login_screen.dart';
import '../app/auth/screens/register_screen.dart';
import '../app/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String history = '/history';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case chat:
        return MaterialPageRoute(builder: (_) => const Chat());
      case history:
        return MaterialPageRoute(builder: (_) => const History());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
