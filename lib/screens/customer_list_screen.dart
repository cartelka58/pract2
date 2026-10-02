import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/notifiers.dart';
import '../widgets/entity_table.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});
  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerListNotifier>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<CustomerListNotifier>();
    final rose = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people),
            SizedBox(width: 8),
            Text('Покупатели'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'К букетам',
            icon: const Icon(Icons.local_florist),
            onPressed: () => context.go('/'),
          ),
          IconButton(
            tooltip: 'Добавить',
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/customers/new'),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text('Показать удалённые', style: TextStyle(color: rose)),
                  const SizedBox(width: 8),
                  Switch(
                    value: n.includeDeleted,
                    onChanged: (v) => n.toggleIncludeDeleted(v),
                  ),
                ],
              ),
            ),
            Expanded(child: _body(n, rose)),
          ],
        ),
      ),
    );
  }

  Widget _body(CustomerListNotifier n, Color rose) {
    switch (n.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return Center(child: CircularProgressIndicator(color: rose));
      case LoadStatus.error:
        return Center(child: Text('Ошибка: ${n.error}'));
      case LoadStatus.success:
        if (n.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_florist, size: 72, color: rose),
                const SizedBox(height: 16),
                Text(
                  'Здесь пока пусто',
                  style: TextStyle(fontSize: 20, color: rose),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: EntityTable<Customer>(
              items: n.items,
              idOf: (c) => c.id,
              onRowTap: (c) => context.go('/customers/${c.id}'),
              isDeleted: (c) => c.isDeleted,
              columns: [
                TableColumnSpec(
                  label: 'Фамилия',
                  build: (c) => Text(c.lastName),
                ),
                TableColumnSpec(label: 'Имя', build: (c) => Text(c.firstName)),
                TableColumnSpec(label: 'Email', build: (c) => Text(c.email)),
                TableColumnSpec(label: 'Телефон', build: (c) => Text(c.phone)),
                TableColumnSpec(
                  label: 'Карта',
                  build: (c) => Text(c.card?.number ?? '—'),
                ),
                TableColumnSpec(
                  label: 'Скидка',
                  build: (c) => Text(
                    c.card == null ? '—' : '${c.card!.discountPercent}%',
                  ),
                ),
              ],
              actions: (c) => [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Редактировать',
                  onPressed: () => context.go('/customers/${c.id}/edit'),
                ),
                if (!c.isDeleted)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => n.softDelete(c.id),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () => n.restore(c.id),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () => n.hardDelete(c.id),
                ),
              ],
            ),
          ),
        );
    }
  }
}
