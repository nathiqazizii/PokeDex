import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import 'auth_controller.dart';

class FavoriteController extends GetxController {
  final SupabaseService _service = SupabaseService.instance;

  /// Id Pokémon favorit, terbaru di depan.
  final RxList<int> ids = <int>[].obs;
  final RxBool loading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn) load();

    // Muat ulang saat login, kosongkan saat logout.
    ever<User?>(auth.user, (u) {
      if (u != null) {
        load();
      } else {
        ids.clear();
      }
    });
  }

  bool isFavorite(int id) => ids.contains(id);

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      ids.assignAll(await _service.fetchFavorites());
    } catch (_) {
      error.value = 'Gagal memuat favorit. Periksa koneksi internet';
    } finally {
      loading.value = false;
    }
  }

  /// Tambah/hapus favorit. Mengembalikan pesan error, atau null bila berhasil.
  Future<String?> toggle(int id) async {
    final wasFavorite = ids.contains(id);

    // Perbarui UI lebih dulu, batalkan bila gagal.
    if (wasFavorite) {
      ids.remove(id);
    } else {
      ids.insert(0, id);
    }

    try {
      if (wasFavorite) {
        await _service.removeFavorite(id);
      } else {
        await _service.addFavorite(id);
      }
      return null;
    } catch (_) {
      if (wasFavorite) {
        ids.insert(0, id);
      } else {
        ids.remove(id);
      }
      return 'Gagal memperbarui favorit. Periksa koneksi internet';
    }
  }
}
