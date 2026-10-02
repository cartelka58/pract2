import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class SupplierDetailScreen extends StatefulWidget {
  final int id;
  const SupplierDetailScreen({super.key, required this.id});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  late Future<Supplier?> _future;
  int _bouquetCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<SupplierRepository>();
    final s = await repo.findById(widget.id);
    final count = await repo.countBouquets(widget.id);
    if (!mounted) return;
    setState(() {
      _future = Future.value(s);
      _bouquetCount = count;
    });
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
            Icon(Icons.local_shipping),
            SizedBox(width: 8),
            Text('Поставщик'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'К списку',
            icon: const Icon(Icons.list),
            onPressed: () => context.go('/suppliers'),
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
            child: FutureBuilder<Supplier?>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator(color: rose));
                }
                final s = snap.data;
                if (s == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 72, color: rose),
                        const SizedBox(height: 16),
                        Text(
                          'Поставщик с id=${widget.id} не найден',
                          style: TextStyle(color: rose, fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.go('/suppliers'),
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
                              Icon(Icons.local_shipping, color: rose, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  s.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: rose,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          _row('Телефон', s.phone),
                          _row('Город', s.city),
                          _row('Связанных букетов', '$_bouquetCount'),
                          if (s.isDeleted)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, color: lavender),
                                    const SizedBox(width: 8),
                                    const Text('Логически удалён'),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton.icon(
                                onPressed: () =>
                                    context.go('/suppliers/${s.id}/edit'),
                                icon: const Icon(Icons.edit),
                                label: const Text('Редактировать'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => context.go('/suppliers'),
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
