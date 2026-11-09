import 'package:flutter/material.dart';

import '../utils/pokemon_utils.dart';

/// Chip pilihan untuk filter tipe di beranda.
class TypeChip extends StatelessWidget {
  final String type;
  final bool selected;
  final VoidCallback onTap;

  const TypeChip({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = typeColor(type);
    return ChoiceChip(
      label: Text(prettyName(type)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: color,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.w600 : null,
      ),
    );
  }
}

/// Lencana tipe (tidak interaktif) untuk halaman detail.
class TypeBadge extends StatelessWidget {
  final String type;

  const TypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: typeColor(type),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        prettyName(type),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
