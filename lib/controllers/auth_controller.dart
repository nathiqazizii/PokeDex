import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../routes/app_routes.dart';
import '../services/supabase_service.dart';

class AuthResult {
  final bool ok;
  final String? message;
  const AuthResult(this.ok, [this.message]);
}

class AuthController extends GetxController {
  final SupabaseService _service = SupabaseService.instance;

  final Rxn<User> user = Rxn<User>();
  final Rxn<Profile> profile = Rxn<Profile>();
  final RxBool loading = false.obs;

  StreamSubscription<AuthState>? _sub;

  bool get isLoggedIn => user.value != null;

  @override
  void onInit() {
    super.onInit();
    user.value = _service.currentUser;
    if (user.value != null) loadProfile();

    _sub = _service.authChanges.listen((state) {
      user.value = state.session?.user;
      if (user.value != null) {
        loadProfile();
      } else {
        profile.value = null;
      }
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<AuthResult> register(
      String email, String password, String username) async {
    loading.value = true;
    try {
      final res = await _service.signUp(
        email: email,
        password: password,
        username: username,
      );
      if (res.session == null) {
        // Konfirmasi email aktif di Supabase: belum ada sesi.
        return const AuthResult(true,
            'Registrasi berhasil. Cek email untuk konfirmasi, lalu login.');
      }
      return const AuthResult(true);
    } catch (e) {
      return AuthResult(false, _friendly(e));
    } finally {
      loading.value = false;
    }
  }

  Future<AuthResult> login(String email, String password) async {
    loading.value = true;
    try {
      await _service.signIn(email: email, password: password);
      return const AuthResult(true);
    } catch (e) {
      return AuthResult(false, _friendly(e));
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _service.signOut();
    } catch (_) {
      // Tetap lanjut: sesi lokal dibersihkan di bawah.
    }
    user.value = null;
    profile.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> loadProfile() async {
    try {
      profile.value = await _service.fetchProfile();
    } catch (_) {
      // Profil gagal dimuat (mis. offline); UI menampilkan fallback.
    }
  }

  Future<AuthResult> updateUsername(String username) async {
    try {
      await _service.updateUsername(username);
      await loadProfile();
      return const AuthResult(true, 'Username berhasil diperbarui');
    } catch (e) {
      return AuthResult(false, _friendly(e));
    }
  }

  String _friendly(Object e) {
    if (e is AuthException) {
      final m = e.message.toLowerCase();
      if (m.contains('invalid login credentials')) {
        return 'Email atau password salah';
      }
      if (m.contains('already registered') ||
          m.contains('already been registered')) {
        return 'Email sudah terdaftar';
      }
      if (m.contains('email not confirmed')) {
        return 'Email belum dikonfirmasi. Cek kotak masuk email kamu';
      }
      if (m.contains('socketexception') || m.contains('failed host lookup')) {
        return 'Tidak ada koneksi internet';
      }
      return e.message;
    }
    if (e is SocketException) return 'Tidak ada koneksi internet';
    if (e is PostgrestException) return e.message;
    return 'Terjadi kesalahan: $e';
  }
}
