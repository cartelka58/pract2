import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int id;
  const CustomerDetailScreen({super.key, required this.id});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Future<Customer?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CustomerRepository>().findById(widget.id);
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
            Icon(Icons.people),
            SizedBox(width: 8),
            Text('Покупатель'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'К списку',
            icon: const Icon(Icons.list),
            onPressed: () => context.go('/customers'),
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
            child: FutureBuilder<Customer?>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator(color: rose));
                }
                final c = snap.data;
                if (c == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 72, color: rose),
                        const SizedBox(height: 16),
                        Text(
                          'Покупатель с id=${widget.id} не найден',
                          style: TextStyle(color: rose, fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.go('/customers'),
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
                              Icon(Icons.people, color: rose, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  c.fullName,
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
                          _row('Email', c.email),
                          _row('Телефон', c.phone),

                          const SizedBox(height: 16),
                          Text(
                            'Карта лояльности',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: rose,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (c.card == null)
                            Text(
                              '— карта не оформлена —',
                              style: TextStyle(color: lavender),
                            )
                          else ...[
                            _row('Номер', c.card!.number),
                            _row('Скидка', '${c.card!.discountPercent}%'),
                            _row(
                              'Выдана',
                              c.card!.issuedAt
                                  .toIso8601String()
                                  .split('T')
                                  .first,
                            ),
                          ],
                          if (c.isDeleted)
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
                                    context.go('/customers/${c.id}/edit'),
                                icon: const Icon(Icons.edit),
                                label: const Text('Редактировать'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => context.go('/customers'),
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
            width: 140,
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
