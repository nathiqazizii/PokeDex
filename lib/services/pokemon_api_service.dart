import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../database/local_database.dart';
import '../models/pokemon.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Pemanggil PokéAPI. Hasil detail, daftar nama, dan daftar tipe di-cache
/// ke [LocalDatabase].
class PokemonApiService {
  PokemonApiService._();
  static final PokemonApiService instance = PokemonApiService._();

  static const Duration _timeout = Duration(seconds: 15);

  /// Id >= 10000 adalah bentuk alternatif (mega, regional, dsb.), tidak ditampilkan.
  static const int _maxId = 10000;
  static const Set<String> _hiddenTypes = {'unknown', 'shadow', 'stellar'};

  final LocalDatabase _db = LocalDatabase.instance;

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('${AppConfig.pokeApiBase}$path');
    try {
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode == 200) return jsonDecode(res.body);
      if (res.statusCode == 404) throw const ApiException('Data tidak ditemukan');
      throw ApiException('Server bermasalah (${res.statusCode})');
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException('Tidak ada koneksi internet');
    } on http.ClientException {
      throw const ApiException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw const ApiException('Koneksi time out, coba lagi');
    } on FormatException {
      throw const ApiException('Format data dari server tidak valid');
    }
  }

  List<PokemonSummary> _parseList(List<dynamic> raw) => raw
      .map((e) => PokemonSummary.fromListItem(e as Map<String, dynamic>))
      .where((p) => p.id < _maxId)
      .toList();

  /// Satu halaman daftar Pokémon (untuk infinite scroll).
  Future<List<PokemonSummary>> fetchPage({
    required int offset,
    required int limit,
  }) async {
    final data = await _get('/pokemon?limit=$limit&offset=$offset')
        as Map<String, dynamic>;
    return _parseList(data['results'] as List<dynamic>);
  }

  /// Seluruh nama Pokémon (untuk pencarian lokal). Di-cache.
  Future<List<PokemonSummary>> fetchAllNames() async {
    final cached = _db.getNames();
    if (cached != null && cached.isNotEmpty) return cached;

    final data =
        await _get('/pokemon?limit=100000&offset=0') as Map<String, dynamic>;
    final list = _parseList(data['results'] as List<dynamic>);
    await _db.saveNames(list);
    return list;
  }

  /// Daftar tipe untuk filter. Di-cache.
  Future<List<String>> fetchTypes() async {
    final cached = _db.getTypes();
    if (cached != null && cached.isNotEmpty) return cached;

    final data = await _get('/type') as Map<String, dynamic>;
    final types = (data['results'] as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>)['name'] as String)
        .where((t) => !_hiddenTypes.contains(t))
        .toList();
    await _db.saveTypes(types);
    return types;
  }

  /// Pokémon dengan tipe tertentu, terurut berdasarkan id.
  Future<List<PokemonSummary>> fetchByType(String type) async {
    final data = await _get('/type/$type') as Map<String, dynamic>;
    final list = (data['pokemon'] as List<dynamic>)
        .map((e) => PokemonSummary.fromListItem(
            (e as Map<String, dynamic>)['pokemon'] as Map<String, dynamic>))
        .where((p) => p.id < _maxId)
        .toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  /// Detail satu Pokémon. Di-cache.
  Future<Pokemon> fetchDetail(int id) async {
    final cached = _db.getPokemon(id);
    if (cached != null) return cached;

    final data = await _get('/pokemon/$id') as Map<String, dynamic>;
    final pokemon = Pokemon.fromApi(data);
    await _db.savePokemon(pokemon);
    return pokemon;
  }
}
