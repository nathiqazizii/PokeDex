import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../database/local_database.dart';
import '../models/pokemon.dart';
import '../services/pokemon_api_service.dart';

class PokemonController extends GetxController {
  static const int pageSize = 20;

  final PokemonApiService _api = PokemonApiService.instance;
  final LocalDatabase _db = LocalDatabase.instance;

  /// Field pencarian dipegang di sini agar tetap sama di semua halaman.
  final TextEditingController searchText = TextEditingController();

  final RxList<PokemonSummary> items = <PokemonSummary>[].obs;
  final RxList<String> types = <String>[].obs;
  final RxList<String> history = <String>[].obs;
  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxnString error = RxnString();
  final RxString query = ''.obs;
  final RxnString selectedType = RxnString();

  int _offset = 0;
  int _requestToken = 0;
  List<PokemonSummary>? _allNames;

  bool get isFiltering =>
      query.value.trim().isNotEmpty || selectedType.value != null;

  @override
  void onInit() {
    super.onInit();
    history.assignAll(_db.getHistory());
    debounce<String>(query, (_) => reload(),
        time: const Duration(milliseconds: 400));
    loadTypes();
    reload();
  }

  @override
  void onClose() {
    searchText.dispose();
    super.onClose();
  }

  // ---- Daftar, pencarian, filter ----

  Future<void> reload() async {
    final token = ++_requestToken;
    loading.value = true;
    error.value = null;
    items.clear();
    _offset = 0;
    hasMore.value = true;
    if (types.isEmpty) loadTypes();

    try {
      if (!isFiltering) {
        final page = await _fetchPage(0);
        if (token != _requestToken) return;
        items.assignAll(page);
        _offset = pageSize;
        hasMore.value = page.length == pageSize;
      } else {
        var base = selectedType.value != null
            ? await _api.fetchByType(selectedType.value!)
            : await _names();
        final q = query.value.trim().toLowerCase();
        if (q.isNotEmpty) {
          base = base
              .where((p) => p.name.contains(q) || p.id.toString() == q)
              .toList();
        }
        if (token != _requestToken) return;
        items.assignAll(base);
        hasMore.value = false;
      }
    } on ApiException catch (e) {
      if (token == _requestToken) error.value = e.message;
    } catch (_) {
      if (token == _requestToken) error.value = 'Terjadi kesalahan tak terduga';
    } finally {
      if (token == _requestToken) loading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isFiltering || loading.value || loadingMore.value || !hasMore.value) {
      return;
    }
    loadingMore.value = true;
    try {
      final page = await _fetchPage(_offset);
      items.addAll(page);
      _offset += pageSize;
      hasMore.value = page.length == pageSize;
    } on ApiException catch (e) {
      Get.snackbar('Gagal memuat', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      loadingMore.value = false;
    }
  }

  /// Ambil satu halaman; bila offline, pakai daftar nama di cache.
  Future<List<PokemonSummary>> _fetchPage(int offset) async {
    try {
      return await _api.fetchPage(offset: offset, limit: pageSize);
    } on ApiException {
      final cached = _db.getNames();
      if (cached == null || cached.isEmpty) rethrow;
      return cached.skip(offset).take(pageSize).toList();
    }
  }

  Future<List<PokemonSummary>> _names() async {
    return _allNames ??= await _api.fetchAllNames();
  }

  Future<List<PokemonSummary>> ensureNames() => _names();

  Future<void> loadTypes() async {
    try {
      types.assignAll(await _api.fetchTypes());
    } catch (_) {
      // Filter tipe tidak tersedia sementara; dicoba lagi saat reload.
    }
  }

  void onQueryChanged(String value) => query.value = value;

  void setType(String? type) {
    selectedType.value = selectedType.value == type ? null : type;
    reload();
  }

  void clearSearch() {
    searchText.clear();
    query.value = '';
  }

  // ---- Riwayat pencarian ----

  Future<void> submitSearch(String value) async {
    final q = value.trim();
    if (q.isEmpty) return;
    await _db.addHistory(q);
    history.assignAll(_db.getHistory());
  }

  void useHistory(String q) {
    searchText.text = q;
    searchText.selection = TextSelection.collapsed(offset: q.length);
    query.value = q;
  }

  Future<void> removeHistory(String q) async {
    await _db.removeHistory(q);
    history.assignAll(_db.getHistory());
  }

  Future<void> clearHistory() async {
    await _db.clearHistory();
    history.clear();
  }

  // ---- Detail ----

  Future<Pokemon> detail(int id) => _api.fetchDetail(id);

  /// Ubah daftar id (mis. favorit) menjadi ringkasan lengkap dengan nama.
  List<PokemonSummary> summariesFor(
      List<int> ids, Map<int, PokemonSummary> known) {
    return ids
        .map((id) => known[id] ?? PokemonSummary(id: id, name: 'pokemon-$id'))
        .toList();
  }
}
