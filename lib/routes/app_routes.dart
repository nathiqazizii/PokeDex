import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/about_page.dart';
import '../pages/detail_page.dart';
import '../pages/history_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/splash_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String history = '/history';
  static const String about = '/about';

  static final List<GetPage<dynamic>> pages = [
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: register, page: () => const RegisterPage()),
    GetPage(
      name: home,
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: detail,
      page: () => const DetailPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: history,
      page: () => const HistoryPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: about,
      page: () => const AboutPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

/// Proteksi halaman: tanpa sesi login, diarahkan ke halaman Login.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
