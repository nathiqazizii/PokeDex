import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorite_controller.dart';
import '../controllers/pokemon_controller.dart';
import '../models/pokemon.dart';
import '../routes/app_routes.dart';
import '../utils/pokemon_utils.dart';
import '../widgets/loading.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteController _fav = Get.find<FavoriteController>();
  final PokemonController _pokemon = Get.find<PokemonController>();
  late final Future<List<PokemonSummary>> _namesFuture;

  @override
  void initState() {
    super.initState();
    // Nama dipakai untuk menampilkan favorit; bila gagal, pakai nama cadangan.
    _namesFuture = _pokemon
        .ensureNames()
        .catchError((_) => <PokemonSummary>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit')),
      body: FutureBuilder<List<PokemonSummary>>(
        future: _namesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final known = {
            for (final p in snapshot.data ?? const <PokemonSummary>[]) p.id: p,
          };
          return Obx(() => _buildList(known));
        },
      ),
    );
  }

  Widget _buildList(Map<int, PokemonSummary> known) {
    if (_fav.loading.value && _fav.ids.isEmpty) return const LoadingView();

    final error = _fav.error.value;
    if (error != null && _fav.ids.isEmpty) {
      return ErrorView(message: error, onRetry: _fav.load);
    }

    if (_fav.ids.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fav.load,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            EmptyView(
              message: 'Belum ada favorit.\nKetuk ♥ pada Pokémon untuk menyimpannya.',
              icon: Icons.favorite_border,
            ),
          ],
        ),
      );
    }

    final list = _pokemon.summariesFor(_fav.ids.toList(), known);
    return RefreshIndicator(
      onRefresh: _fav.load,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final p = list[i];
          return ListTile(
            leading: SizedBox(
              width: 56,
              height: 56,
              child: Image.network(
                p.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.catching_pokemon, color: Colors.grey),
              ),
            ),
            title: Text(prettyName(p.name)),
            subtitle: Text(formatId(p.id)),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              tooltip: 'Hapus dari favorit',
              onPressed: () async {
                final err = await _fav.toggle(p.id);
                if (err != null) {
                  Get.snackbar('Gagal', err, snackPosition: SnackPosition.BOTTOM);
                }
              },
            ),
            onTap: () => Get.toNamed(AppRoutes.detail, arguments: p),
          );
        },
      ),
    );
  }
}
