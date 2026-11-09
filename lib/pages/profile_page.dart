import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../database/local_database.dart';
import '../routes/app_routes.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../utils/validators.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController _auth = Get.find<AuthController>();
  final LocalDatabase _db = LocalDatabase.instance;

  late bool _reminder = _db.reminderEnabled;
  String? _locationText;
  bool _locating = false;

  Future<void> _editUsername() async {
    final controller =
        TextEditingController(text: _auth.profile.value?.username ?? '');
    final newName = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Ubah username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (newName == null) return;

    final invalid = Validators.username(newName);
    if (invalid != null) {
      Get.snackbar('Tidak valid', invalid, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final result = await _auth.updateUsername(newName);
    Get.snackbar(
      result.ok ? 'Berhasil' : 'Gagal',
      result.message ?? '',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _toggleReminder(bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        Get.snackbar(
          'Izin ditolak',
          'Aktifkan izin notifikasi untuk PokéDex di pengaturan perangkat',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await NotificationService.instance.enableDailyReminder();
    } else {
      await NotificationService.instance.disableDailyReminder();
    }
    await _db.setReminder(value);
    if (mounted) setState(() => _reminder = value);
  }

  Future<void> _testNotification() async {
    final granted = await NotificationService.instance.requestPermission();
    if (!granted) {
      Get.snackbar(
        'Izin ditolak',
        'Aktifkan izin notifikasi untuk PokéDex di pengaturan perangkat',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    await NotificationService.instance.showNow();
  }

  Future<void> _showLocation() async {
    setState(() => _locating = true);
    try {
      final pos = await LocationService.instance.getCurrentPosition();
      if (mounted) {
        setState(() {
          _locationText =
              'Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)}';
        });
      }
    } on LocationException catch (e) {
      Get.snackbar('Lokasi', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Lokasi', 'Gagal mengambil lokasi',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _confirmLogout() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok == true) await _auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          Obx(() {
            final username = _auth.profile.value?.username ?? '';
            final email = _auth.user.value?.email ?? '-';
            final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    child: Text(initial, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username.isEmpty ? 'Pengguna' : username,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(email),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Ubah username',
                    onPressed: _editUsername,
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat pencarian'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(AppRoutes.history),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Pengingat harian'),
            subtitle: const Text('Ajak menjelajahi Pokémon setiap hari'),
            value: _reminder,
            onChanged: _toggleReminder,
          ),
          ListTile(
            leading: const Icon(Icons.notification_add_outlined),
            title: const Text('Coba notifikasi sekarang'),
            onTap: _testNotification,
          ),
          ListTile(
            leading: const Icon(Icons.my_location),
            title: const Text('Lokasi saya'),
            subtitle: Text(_locationText ?? 'Ketuk untuk menampilkan koordinat'),
            trailing: _locating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _locating ? null : _showLocation,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(AppRoutes.about),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }
}
