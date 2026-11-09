import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pokemon.dart';

/// Penyimpanan lokal berbasis SharedPreferences: cache data PokéAPI
/// (detail, daftar nama, daftar tipe) dan riwayat pencarian.
/// Cache belum memiliki masa kedaluwarsa.
class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  static const String _kNames = 'cache_names';
  static const String _kTypes = 'cache_types';
  static const String _kHistory = 'search_history';
  static const String _kReminder = 'reminder_enabled';
  static const int _maxHistory = 20;

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---- Cache detail Pokémon ----

  Pokemon? getPokemon(int id) {
    final raw = _prefs.getString('pokemon_$id');
    if (raw == null) return null;
    try {
      return Pokemon.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePokemon(Pokemon pokemon) async {
    await _prefs.setString('pokemon_${pokemon.id}', jsonEncode(pokemon.toJson()));
  }

  // ---- Cache daftar nama ----

  List<PokemonSummary>? getNames() {
    final raw = _prefs.getString(_kNames);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => PokemonSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNames(List<PokemonSummary> names) async {
    await _prefs.setString(
        _kNames, jsonEncode(names.map((e) => e.toJson()).toList()));
  }

  // ---- Cache daftar tipe ----

  List<String>? getTypes() {
    final list = _prefs.getStringList(_kTypes);
    return list == null ? null : List<String>.from(list);
  }

  Future<void> saveTypes(List<String> types) async {
    await _prefs.setStringList(_kTypes, types);
  }

  // ---- Riwayat pencarian ----

  List<String> getHistory() =>
      List<String>.from(_prefs.getStringList(_kHistory) ?? const <String>[]);

  Future<void> addHistory(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final list = getHistory()
      ..removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    list.insert(0, q);
    await _prefs.setStringList(_kHistory, list.take(_maxHistory).toList());
  }

  Future<void> removeHistory(String query) async {
    final list = getHistory()..remove(query);
    await _prefs.setStringList(_kHistory, list);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_kHistory);
  }

  // ---- Pengaturan pengingat ----

  bool get reminderEnabled => _prefs.getBool(_kReminder) ?? false;

  Future<void> setReminder(bool value) async {
    await _prefs.setBool(_kReminder, value);
  }
}
