import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/notifiers.dart';
import '../widgets/entity_table.dart';
import '../widgets/paginator.dart';

class BouquetListScreen extends StatefulWidget {
  const BouquetListScreen({super.key});
  @override
  State<BouquetListScreen> createState() => _BouquetListScreenState();
}

class _BouquetListScreenState extends State<BouquetListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _urlSyncStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final n = context.read<BouquetListNotifier>();
      final uri = GoRouterState.of(context).uri;
      final params = uri.queryParameters;
      if (params.isNotEmpty) {
        n.applyQuery(BouquetListNotifier.queryFromUri(params));
        _searchController.text = params['search'] ?? '';
      } else {
        n.load();
      }
      _urlSyncStarted = true;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final n = context.read<BouquetListNotifier>();
      n.applyQuery(n.query.copyWith(search: value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<BouquetListNotifier>();
    final categories = context.watch<CategoryListNotifier>().items;
    final suppliers = context.watch<SupplierListNotifier>().items;
    final isNarrow = MediaQuery.of(context).size.width < 600;
    final rose = Theme.of(context).colorScheme.primary;
    final lavender = Theme.of(context).colorScheme.secondary;

    if (_urlSyncStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final qs = n.toQueryString();
        final path = GoRouterState.of(context).uri.path;
        final newLocation = qs.isEmpty ? path : '$path?$qs';
        final currentLocation = GoRouterState.of(context).uri.toString();
        if (currentLocation != newLocation) {
          context.go(newLocation);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_florist),
            SizedBox(width: 8),
            Text('Букеты'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Добавить букет',
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/bouquets/new'),
          ),
          IconButton(
            tooltip: 'Категории',
            icon: const Icon(Icons.category),
            onPressed: () => context.go('/categories'),
          ),
          IconButton(
            tooltip: 'Поставщики',
            icon: const Icon(Icons.local_shipping),
            onPressed: () => context.go('/suppliers'),
          ),
          IconButton(
            tooltip: 'Флористы',
            icon: const Icon(Icons.emoji_nature),
            onPressed: () => context.go('/florists'),
          ),
          IconButton(
            tooltip: 'Покупатели',
            icon: const Icon(Icons.people),
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
        child: Column(
          children: [
            _filters(n, categories, suppliers, rose, lavender),
            if (n.hasSelection)
              Material(
                color: rose.withValues(alpha: 0.15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: rose),
                      const SizedBox(width: 8),
                      Text(
                        'Выбрано: ${n.selected.length}',
                        style: TextStyle(
                          color: rose,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () async {
                          final ok = await _confirm(context);
                          if (ok == true) await n.deleteSelected();
                        },
                        icon: const Icon(Icons.delete_sweep),
                        label: const Text('Удалить выбранные'),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: _body(n, categories, suppliers, isNarrow, rose, lavender),
            ),
            if (n.status == LoadStatus.success)
              Paginator(
                page: n.result.page,
                totalPages: n.result.totalPages,
                total: n.result.total,
                size: n.result.size,
                onPage: (p) => n.applyQuery(n.query.copyWith(page: p)),
                onSize: (s) => n.applyQuery(n.query.copyWith(size: s, page: 1)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filters(
    BouquetListNotifier n,
    List<Category> categories,
    List<Supplier> suppliers,
    Color rose,
    Color lavender,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: lavender.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  labelText: 'Поиск по названию или артикулу',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<int?>(
                initialValue: n.query.categoryId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Категория'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Все категории'),
                  ),
                  for (final c in categories)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => n.applyQuery(n.query.copyWith(categoryId: v)),
              ),
            ),
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<int?>(
                initialValue: n.query.supplierId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Поставщик'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Все поставщики'),
                  ),
                  for (final s in suppliers)
                    DropdownMenuItem(value: s.id, child: Text(s.name)),
                ],
                onChanged: (v) => n.applyQuery(n.query.copyWith(supplierId: v)),
              ),
            ),
            SizedBox(
              width: 130,
              child: TextField(
                decoration: const InputDecoration(labelText: 'Цена от, ₽'),
                keyboardType: TextInputType.number,
                onSubmitted: (v) => n.applyQuery(
                  n.query.copyWith(priceFrom: double.tryParse(v)),
                ),
              ),
            ),
            SizedBox(
              width: 130,
              child: TextField(
                decoration: const InputDecoration(labelText: 'Цена до, ₽'),
                keyboardType: TextInputType.number,
                onSubmitted: (v) =>
                    n.applyQuery(n.query.copyWith(priceTo: double.tryParse(v))),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Показать удалённые', style: TextStyle(color: rose)),
                Switch(
                  value: n.query.includeDeleted,
                  onChanged: (v) =>
                      n.applyQuery(n.query.copyWith(includeDeleted: v)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BouquetListNotifier n,
    List<Category> categories,
    List<Supplier> suppliers,
    bool narrow,
    Color rose,
    Color lavender,
  ) {
    switch (n.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: rose),
              const SizedBox(height: 16),
              Text('Загружаем букеты...', style: TextStyle(color: rose)),
            ],
          ),
        );
      case LoadStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: rose, size: 64),
              const SizedBox(height: 16),
              Text('Ошибка: ${n.error}', style: TextStyle(color: rose)),
            ],
          ),
        );
      case LoadStatus.success:
        if (n.result.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_florist, size: 72, color: rose),
                const SizedBox(height: 16),
                Text(
                  'Здесь пока пусто',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: rose,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Попробуйте изменить условия поиска',
                  style: TextStyle(color: lavender),
                ),
              ],
            ),
          );
        }
        if (narrow) return _cards(n, rose);
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: lavender.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: _table(n, categories),
          ),
        );
    }
  }

  Widget _table(BouquetListNotifier n, List<Category> categories) {
    String catNames(Bouquet b) {
      return b.categoryIds
          .map((id) {
            final matches = categories.where((c) => c.id == id);
            return matches.isEmpty ? '?' : matches.first.name;
          })
          .join(', ');
    }

    return EntityTable<Bouquet>(
      items: n.result.items,
      idOf: (b) => b.id,
      selected: n.selected,
      onToggleSelect: n.toggleSelection,
      onRowTap: (b) => context.go('/bouquets/${b.id}'),
      sortField: n.query.sortField,
      sortAscending: n.query.sortAscending,
      onSort: (field) => n.applyQuery(
        n.query.copyWith(
          sortField: field,
          sortAscending: field == n.query.sortField
              ? !n.query.sortAscending
              : true,
        ),
      ),
      isDeleted: (b) => b.isDeleted,
      columns: [
        TableColumnSpec(
          label: 'Название',
          sortField: 'title',
          build: (b) => Text(b.title),
        ),
        TableColumnSpec(label: 'Артикул', build: (b) => Text(b.sku)),
        TableColumnSpec(
          label: 'Цена, ₽',
          sortField: 'price',
          numeric: true,
          build: (b) => Text(b.price.toStringAsFixed(0)),
        ),
        TableColumnSpec(
          label: 'Стеблей',
          sortField: 'stemCount',
          numeric: true,
          build: (b) => Text('${b.stemCount}'),
        ),
        TableColumnSpec(label: 'Категории', build: (b) => Text(catNames(b))),
        TableColumnSpec(
          label: 'Склад',
          build: (b) => Text('${b.stockAvailable}/${b.stockTotal}'),
        ),
      ],
      actions: (b) => [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Редактировать',
          onPressed: () => context.go('/bouquets/${b.id}/edit'),
        ),
        if (!b.isDeleted)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Логически удалить',
            onPressed: () => n.softDeleteOne(b.id),
          )
        else
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Восстановить',
            onPressed: () => n.restoreOne(b.id),
          ),
        IconButton(
          icon: const Icon(Icons.delete_forever),
          tooltip: 'Удалить насовсем',
          onPressed: () => n.hardDeleteOne(b.id),
        ),
      ],
    );
  }

  Widget _cards(BouquetListNotifier n, Color rose) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: n.result.items.length,
      itemBuilder: (_, i) {
        final b = n.result.items[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Checkbox(
              value: n.selected.contains(b.id),
              onChanged: (_) => n.toggleSelection(b.id),
            ),
            title: Text(
              b.title,
              style: TextStyle(color: rose, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${b.price.toStringAsFixed(0)} ₽ • ${b.stemCount} стеблей • ${b.sku}',
            ),
            onTap: () => context.go('/bouquets/${b.id}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.go('/bouquets/${b.id}/edit'),
                ),
                if (!b.isDeleted)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => n.softDeleteOne(b.id),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () => n.restoreOne(b.id),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<bool?> _confirm(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.deepOrange),
          SizedBox(width: 8),
          Text('Удалить выбранные?'),
        ],
      ),
      content: const Text('Букеты будут логически удалены.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
}
