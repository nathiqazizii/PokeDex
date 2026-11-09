import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'controllers/auth_controller.dart';
import 'controllers/favorite_controller.dart';
import 'controllers/pokemon_controller.dart';
import 'database/local_database.dart';
import 'routes/app_routes.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.isConfigured) {
    runApp(const _ConfigErrorApp());
    return;
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseKey,
  );
  await LocalDatabase.instance.init();
  try {
    await NotificationService.instance.init();
  } catch (_) {
    // Notifikasi opsional; aplikasi tetap berjalan tanpanya.
  }

  runApp(const PokedexApp());
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<PokemonController>(PokemonController(), permanent: true);
    Get.put<FavoriteController>(FavoriteController(), permanent: true);
  }
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PokéDex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.red,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}

/// Ditampilkan bila aplikasi dibuild tanpa `--dart-define` Supabase.
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.settings_suggest, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Konfigurasi Supabase belum diatur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Build aplikasi dengan --dart-define=SUPABASE_URL=... '
                  'dan --dart-define=SUPABASE_PUBLISHABLE_KEY=...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
