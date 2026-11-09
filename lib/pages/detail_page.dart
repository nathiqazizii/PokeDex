import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pokemon_controller.dart';
import '../models/pokemon.dart';
import '../services/pokemon_api_service.dart';
import '../utils/pokemon_utils.dart';
import '../widgets/loading.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/type_chip.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final PokemonController _c = Get.find<PokemonController>();
  late final PokemonSummary _summary;
  late Future<Pokemon> _future;

  @override
  void initState() {
    super.initState();
    _summary = Get.arguments as PokemonSummary;
    _future = _c.detail(_summary.id);
  }

  void _retry() => setState(() => _future = _c.detail(_summary.id));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(prettyName(_summary.name)),
        actions: [FavoriteButton(pokemonId: _summary.id)],
      ),
      body: FutureBuilder<Pokemon>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            final e = snapshot.error;
            return ErrorView(
              message: e is ApiException ? e.message : 'Gagal memuat detail',
              onRetry: _retry,
            );
          }
          return _DetailBody(pokemon: snapshot.data!);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Pokemon pokemon;

  const _DetailBody({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mainColor = typeColor(pokemon.types.first);

    return ListView(
      children: [
        Container(
          color: mainColor.withValues(alpha: 0.25),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: Image.network(
                  pokemon.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.catching_pokemon,
                    size: 120,
                    color: Colors.grey,
                  ),
                ),
              ),
              Text(formatId(pokemon.id),
                  style: textTheme.titleMedium?.copyWith(color: Colors.grey)),
              Text(prettyName(pokemon.name), style: textTheme.headlineMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [for (final t in pokemon.types) TypeBadge(type: t)],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      label: 'Tinggi',
                      value: '${pokemon.heightM.toStringAsFixed(1)} m',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      label: 'Berat',
                      value: '${pokemon.weightKg.toStringAsFixed(1)} kg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Kemampuan', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in pokemon.abilities)
                    Chip(label: Text(prettyName(a))),
                ],
              ),
              const SizedBox(height: 20),
              Text('Statistik Dasar', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final s in pokemon.stats) _StatRow(stat: s, color: mainColor),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final PokemonStat stat;
  final Color color;

  const _StatRow({required this.stat, required this.color});

  @override
  Widget build(BuildContext context) {
    // 255 adalah nilai dasar tertinggi yang mungkin pada satu statistik.
    final fraction = math.min(stat.value / 255, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(statLabel(stat.name))),
          SizedBox(
            width: 36,
            child: Text(
              '${stat.value}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                color: color,
                backgroundColor: color.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
