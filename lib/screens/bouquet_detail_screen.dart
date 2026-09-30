import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../repositories/repositories.dart';
import '../repositories/seed_data.dart';
import '../models/models.dart';

class BouquetDetailScreen extends StatefulWidget {
  final int id;
  const BouquetDetailScreen({super.key, required this.id});

  @override
  State<BouquetDetailScreen> createState() => _BouquetDetailScreenState();
}

class _BouquetDetailScreenState extends State<BouquetDetailScreen> {
  late Future<Bouquet?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<BouquetRepository>().findById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final rose = Theme.of(context).colorScheme.primary;
    final lavender = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_florist),
            SizedBox(width: 8),
            Text('Букет'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'К списку',
            icon: const Icon(Icons.list),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8E1), Color(0xFFFCE4EC), Color(0xFFEDE7F6)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: FutureBuilder<Bouquet?>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator(color: rose));
                }
                final b = snap.data;
                if (b == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 72, color: rose),
                        const SizedBox(height: 16),
                        Text(
                          'Букет с id=${widget.id} не найден',
                          style: TextStyle(color: rose, fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.go('/'),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('К списку'),
                        ),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_florist, color: rose, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  b.title,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: rose,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            b.sku,
                            style: TextStyle(color: lavender, fontSize: 16),
                          ),
                          const Divider(height: 32),
                          _row('Цена', '${b.price.toStringAsFixed(0)} ₽'),
                          _row('Количество стеблей', '${b.stemCount}'),
                          _row(
                            'Категории',
                            b.categoryIds
                                .map((id) => kCategories[id] ?? '?')
                                .join(', '),
                          ),
                          _row('Поставщик', kSuppliers[b.supplierId] ?? '—'),
                          _row(
                            'На складе',
                            '${b.stockAvailable} из ${b.stockTotal}',
                          ),
                          if (b.isDeleted)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete_outline),
                                    SizedBox(width: 8),
                                    Text('Логически удалён'),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              FilledButton.icon(
                                onPressed: () => context.go('/'),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('К списку'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
