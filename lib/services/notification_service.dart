import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notifikasi lokal: pengingat harian untuk menjelajahi Pokémon.
/// Memakai pengulangan harian tidak-eksak sehingga tidak butuh izin alarm eksak.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const int _reminderId = 1;
  static const int _testId = 2;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_reminder',
      'Pengingat Harian',
      channelDescription: 'Pengingat harian untuk menjelajahi Pokémon',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
  );

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> enableDailyReminder() async {
    await _plugin.periodicallyShow(
      _reminderId,
      'PokéDex',
      'Yuk jelajahi Pokémon baru hari ini!',
      RepeatInterval.daily,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> disableDailyReminder() => _plugin.cancel(_reminderId);

  /// Menampilkan notifikasi sekarang juga, untuk mencoba fitur.
  Future<void> showNow() async {
    await _plugin.show(
      _testId,
      'PokéDex',
      'Notifikasi berhasil! Selamat menjelajah Pokémon.',
      _details,
    );
  }
}
