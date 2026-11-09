/// Konfigurasi aplikasi. Nilai Supabase diberikan lewat `--dart-define`
/// sehingga tidak pernah di-commit ke repository.
class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  static const String pokeApiBase = 'https://pokeapi.co/api/v2';

  static String artworkUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}
