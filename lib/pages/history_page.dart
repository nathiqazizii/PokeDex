import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pokemon_controller.dart';
import '../widgets/loading.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _confirmClear(PokemonController c) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus semua riwayat?'),
        content: const Text('Seluruh riwayat pencarian akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) await c.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PokemonController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pencarian'),
        actions: [
          Obx(
            () => IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Hapus semua',
              onPressed: c.history.isEmpty ? null : () => _confirmClear(c),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final list = c.history.toList();
        if (list.isEmpty) {
          return const EmptyView(
            message: 'Belum ada riwayat pencarian',
            icon: Icons.history,
          );
        }
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final q = list[i];
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(q),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Hapus',
                onPressed: () => c.removeHistory(q),
              ),
              onTap: () {
                c.useHistory(q);
                Get.back();
              },
            );
          },
        );
      }),
    );
  }
}
