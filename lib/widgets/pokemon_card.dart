import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorite_controller.dart';
import '../models/pokemon.dart';
import '../utils/pokemon_utils.dart';

/// Tombol hati: tambah/hapus favorit, ikut berubah secara reaktif.
class FavoriteButton extends StatelessWidget {
  final int pokemonId;

  const FavoriteButton({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context) {
    final fav = Get.find<FavoriteController>();
    return Obx(() {
      final isFav = fav.ids.contains(pokemonId);
      return IconButton(
        tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Colors.red : null,
        ),
        onPressed: () async {
          final error = await fav.toggle(pokemonId);
          if (error != null) {
            Get.snackbar('Gagal', error, snackPosition: SnackPosition.BOTTOM);
          }
        },
      );
    });
  }
}

class PokemonCard extends StatelessWidget {
  final PokemonSummary pokemon;
  final VoidCallback onTap;

  const PokemonCard({super.key, required this.pokemon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                children: [
                  Expanded(
                    child: Image.network(
                      pokemon.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) => progress == null
                          ? child
                          : const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.catching_pokemon,
                        size: 56,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatId(pokemon.id),
                    style: textTheme.labelMedium?.copyWith(color: Colors.grey),
                  ),
                  Text(
                    prettyName(pokemon.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: FavoriteButton(pokemonId: pokemon.id),
            ),
          ],
        ),
      ),
    );
  }
}
