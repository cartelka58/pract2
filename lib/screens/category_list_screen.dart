import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/notifiers.dart';
import '../widgets/entity_table.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});
  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryListNotifier>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<CategoryListNotifier>();
    final rose = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category),
            SizedBox(width: 8),
            Text('Категории'),
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
            onPressed: () => context.go('/categories/new'),
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

  Widget _body(CategoryListNotifier n, Color rose) {
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
            child: EntityTable<Category>(
              items: n.items,
              idOf: (c) => c.id,
              onRowTap: (c) => context.go('/categories/${c.id}'),
              isDeleted: (c) => c.isDeleted,
              columns: [
                TableColumnSpec(label: 'Название', build: (c) => Text(c.name)),
                TableColumnSpec(
                  label: 'Описание',
                  build: (c) => Text(c.description),
                ),
              ],
              actions: (c) => [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Редактировать',
                  onPressed: () => context.go('/categories/${c.id}/edit'),
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
