import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

/// Pembungkus klien Supabase: autentikasi, profil, dan favorit.
/// `user_id` pada tabel favorites diisi database (`auth.uid()`),
/// dan RLS memastikan hanya data milik pengguna yang terbaca.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  // ---- Auth ----

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  // ---- Profil ----

  Future<Profile?> fetchProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final row =
        await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  Future<void> updateUsername(String username) async {
    final user = currentUser;
    if (user == null) return;
    await _client
        .from('profiles')
        .update({'username': username}).eq('id', user.id);
  }

  // ---- Favorit ----

  Future<List<int>> fetchFavorites() async {
    final rows = await _client
        .from('favorites')
        .select('pokemon_id')
        .order('created_at', ascending: false);
    return rows.map<int>((r) => r['pokemon_id'] as int).toList();
  }

  Future<void> addFavorite(int pokemonId) async {
    await _client.from('favorites').insert({'pokemon_id': pokemonId});
  }

  Future<void> removeFavorite(int pokemonId) async {
    await _client.from('favorites').delete().eq('pokemon_id', pokemonId);
  }
}
