import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/notifiers.dart';
import '../widgets/entity_table.dart';
import '../widgets/paginator.dart';

class FloristListScreen extends StatefulWidget {
  const FloristListScreen({super.key});
  @override
  State<FloristListScreen> createState() => _FloristListScreenState();
}

class _FloristListScreenState extends State<FloristListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FloristListNotifier>().load();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final n = context.read<FloristListNotifier>();
      n.applyQuery(n.query.copyWith(search: v));
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<FloristListNotifier>();
    final isNarrow = MediaQuery.of(context).size.width < 600;
    final rose = Theme.of(context).colorScheme.primary;
    final lavender = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.spa), SizedBox(width: 8), Text('Флористы')],
        ),
        actions: [
          IconButton(
            tooltip: 'Букеты',
            icon: const Icon(Icons.menu_book),
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
        child: Column(
          children: [
            Padding(
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
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 380,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      labelText: 'Поиск по фамилии, имени, городу',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: _body(n, isNarrow, rose, lavender)),
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

  Widget _body(FloristListNotifier n, bool narrow, Color rose, Color lavender) {
    switch (n.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: rose),
              const SizedBox(height: 16),
              Text('Загружаем флористов...', style: TextStyle(color: rose)),
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
              ],
            ),
          );
        }
        if (narrow) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: n.result.items.length,
            itemBuilder: (_, i) {
              final f = n.result.items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Checkbox(
                    value: n.selected.contains(f.id),
                    onChanged: (_) => n.toggleSelection(f.id),
                  ),
                  title: Text(
                    f.fullName,
                    style: TextStyle(color: rose, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${f.city}, с ${f.experienceYear ?? "—"}'),
                ),
              );
            },
          );
        }
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
            child: EntityTable<Florist>(
              items: n.result.items,
              idOf: (f) => f.id,
              selected: n.selected,
              onToggleSelect: n.toggleSelection,
              onRowTap: (f) => context.go('/florists/${f.id}'),
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
              columns: [
                TableColumnSpec(
                  label: 'Фамилия',
                  sortField: 'lastName',
                  build: (f) => Text(f.lastName),
                ),
                TableColumnSpec(
                  label: 'Имя',
                  sortField: 'firstName',
                  build: (f) => Text(f.firstName),
                ),
                TableColumnSpec(
                  label: 'Город',
                  sortField: 'city',
                  build: (f) => Text(f.city),
                ),
                TableColumnSpec(
                  label: 'В профессии с',
                  build: (f) => Text('${f.experienceYear ?? "—"}'),
                ),
              ],
            ),
          ),
        );
    }
  }
}
