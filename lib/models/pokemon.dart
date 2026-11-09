import '../config.dart';

/// Data ringkas untuk daftar (id + nama), cukup untuk kartu di grid.
class PokemonSummary {
  final int id;
  final String name;

  const PokemonSummary({required this.id, required this.name});

  /// Dari item `results` PokéAPI: `{name, url}`; id diambil dari ujung URL.
  factory PokemonSummary.fromListItem(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    return PokemonSummary(
      id: int.parse(segments.last),
      name: json['name'] as String,
    );
  }

  factory PokemonSummary.fromJson(Map<String, dynamic> json) =>
      PokemonSummary(id: json['id'] as int, name: json['name'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  String get imageUrl => AppConfig.artworkUrl(id);
}

class PokemonStat {
  final String name;
  final int value;

  const PokemonStat({required this.name, required this.value});

  factory PokemonStat.fromJson(Map<String, dynamic> json) =>
      PokemonStat(name: json['name'] as String, value: json['value'] as int);

  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}

class Pokemon {
  final int id;
  final String name;
  final List<String> types;

  /// Tinggi dalam desimeter, berat dalam hektogram (satuan asli PokéAPI).
  final int height;
  final int weight;
  final List<String> abilities;
  final List<PokemonStat> stats;

  const Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
  });

  double get heightM => height / 10;
  double get weightKg => weight / 10;
  String get imageUrl => AppConfig.artworkUrl(id);

  /// Dari respons `/pokemon/{id}` PokéAPI.
  factory Pokemon.fromApi(Map<String, dynamic> json) {
    final types = (json['types'] as List<dynamic>)
        .map((t) => (t as Map<String, dynamic>)['type']['name'] as String)
        .toList();
    final abilities = (json['abilities'] as List<dynamic>)
        .map((a) => (a as Map<String, dynamic>)['ability']['name'] as String)
        .toList();
    final stats = (json['stats'] as List<dynamic>).map((s) {
      final m = s as Map<String, dynamic>;
      return PokemonStat(
        name: m['stat']['name'] as String,
        value: m['base_stat'] as int,
      );
    }).toList();

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      types: types,
      height: json['height'] as int,
      weight: json['weight'] as int,
      abilities: abilities,
      stats: stats,
    );
  }

  /// Dari cache lokal (format hasil [toJson]).
  factory Pokemon.fromJson(Map<String, dynamic> json) => Pokemon(
        id: json['id'] as int,
        name: json['name'] as String,
        types: List<String>.from(json['types'] as List<dynamic>),
        height: json['height'] as int,
        weight: json['weight'] as int,
        abilities: List<String>.from(json['abilities'] as List<dynamic>),
        stats: (json['stats'] as List<dynamic>)
            .map((s) => PokemonStat.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'types': types,
        'height': height,
        'weight': weight,
        'abilities': abilities,
        'stats': stats.map((s) => s.toJson()).toList(),
      };
}
