import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../repositories/repositories.dart';
import '../models/models.dart';

class FloristDetailScreen extends StatefulWidget {
  final int id;
  const FloristDetailScreen({super.key, required this.id});

  @override
  State<FloristDetailScreen> createState() => _FloristDetailScreenState();
}

class _FloristDetailScreenState extends State<FloristDetailScreen> {
  late Future<Florist?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<FloristRepository>().findById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final rose = Theme.of(context).colorScheme.primary;
   

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.spa), SizedBox(width: 8), Text('Флорист')],
        ),
        actions: [
          IconButton(
            tooltip: 'К списку',
            icon: const Icon(Icons.list),
            onPressed: () => context.go('/florists'),
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
            child: FutureBuilder<Florist?>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator(color: rose));
                }
                final f = snap.data;
                if (f == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 72, color: rose),
                        const SizedBox(height: 16),
                        Text(
                          'Флорист с id=${widget.id} не найден',
                          style: TextStyle(color: rose, fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.go('/florists'),
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
                              Icon(Icons.spa, color: rose, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  f.fullName,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: rose,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          _row('Имя', f.firstName),
                          _row('Фамилия', f.lastName),
                          _row('Город', f.city),
                          _row('В профессии с', '${f.experienceYear ?? "—"}'),
                          if (f.isDeleted)
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
                                onPressed: () => context.go('/florists'),
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
