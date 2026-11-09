import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.catching_pokemon, size: 72, color: Colors.red),
          const SizedBox(height: 8),
          Text('PokéDex',
              textAlign: TextAlign.center, style: textTheme.headlineMedium),
          const Text('Versi 1.0.0', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const Text(
            'Ensiklopedia Pokémon yang mengambil data dari PokéAPI, dengan '
            'autentikasi dan penyimpanan favorit per pengguna di Supabase.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Proyek Akhir Praktikum Pemrograman Mobile (Flutter).',
          ),
          const SizedBox(height: 24),
          Text('Teknologi', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Flutter • Dart • GetX • http • supabase_flutter • '
            'shared_preferences • flutter_local_notifications • geolocator',
          ),
          const SizedBox(height: 24),
          Text('Sumber & Atribusi', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Data: PokéAPI (pokeapi.co)'),
          const Text('Backend: Supabase (supabase.com)'),
          const SizedBox(height: 12),
          Text(
            'Pokémon dan nama karakter terkait adalah merek dagang Nintendo / '
            'Game Freak / The Pokémon Company. Aplikasi ini dibuat untuk '
            'tujuan pembelajaran.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
