import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/auth_notifier.dart';
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
    final auth = context.watch<AuthNotifier>();
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 800;
    final hideActionsInMenu = width < 600;
    final rose = Theme.of(context).colorScheme.primary;
    final lavender = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.spa), SizedBox(width: 8), Text('Флористы')],
        ),
        actions: [
          if (hideActionsInMenu)
            PopupMenuButton<String>(
              tooltip: 'Меню',
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthNotifier>().logout();
                  if (!context.mounted) return;
                  context.go('/login');
                  return;
                }
                context.go(value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: '/', child: Text('К букетам')),
                if (auth.has(Role.florist))
                  const PopupMenuItem(
                    value: '/florists/new',
                    child: Text('Добавить флориста'),
                  ),
                const PopupMenuItem(value: 'logout', child: Text('Выйти')),
              ],
            )
          else ...[
            IconButton(
              tooltip: 'К букетам',
              icon: const Icon(Icons.local_florist),
              onPressed: () => context.go('/'),
            ),
            if (auth.has(Role.florist))
              IconButton(
                tooltip: 'Добавить флориста',
                icon: const Icon(Icons.add),
                onPressed: () => context.go('/florists/new'),
              ),
            IconButton(
              tooltip: 'Выйти',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await context.read<AuthNotifier>().logout();
                if (!context.mounted) return;
                context.go('/login');
              },
            ),
          ],
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
                  width: double.infinity,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
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
        return Center(child: CircularProgressIndicator(color: rose));
      case LoadStatus.error:
        return Center(child: Text('Ошибка: ${n.error}'));
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
                  style: TextStyle(fontSize: 20, color: rose),
                ),
              ],
            ),
          );
        }

        final auth = context.watch<AuthNotifier>();
        final canEdit = auth.has(Role.florist);

        if (narrow) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: n.result.items.length,
            itemBuilder: (_, i) {
              final f = n.result.items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    f.fullName,
                    style: TextStyle(color: rose, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${f.city}, с ${f.experienceYear ?? "—"}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => context.go('/florists/${f.id}'),
                  trailing: canEdit
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                context.go('/florists/${f.id}/edit');
                                break;
                              case 'soft-delete':
                                n.softDeleteOne(f.id);
                                break;
                              case 'restore':
                                n.restoreOne(f.id);
                                break;
                              case 'hard-delete':
                                n.hardDeleteOne(f.id);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Редактировать'),
                            ),
                            if (!f.isDeleted)
                              const PopupMenuItem(
                                value: 'soft-delete',
                                child: Text('Удалить'),
                              )
                            else
                              const PopupMenuItem(
                                value: 'restore',
                                child: Text('Восстановить'),
                              ),
                            if (auth.has(Role.admin))
                              const PopupMenuItem(
                                value: 'hard-delete',
                                child: Text('Удалить насовсем'),
                              ),
                          ],
                        )
                      : null,
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
              onToggleSelect: canEdit ? n.toggleSelection : null,
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
              isDeleted: (f) => f.isDeleted,
              columns: [
                TableColumnSpec(
                  label: 'Фамилия',
                  sortField: 'lastName',
                  build: (f) =>
                      Text(f.lastName, overflow: TextOverflow.ellipsis),
                ),
                TableColumnSpec(
                  label: 'Имя',
                  sortField: 'firstName',
                  build: (f) =>
                      Text(f.firstName, overflow: TextOverflow.ellipsis),
                ),
                TableColumnSpec(
                  label: 'Город',
                  sortField: 'city',
                  build: (f) => Text(f.city, overflow: TextOverflow.ellipsis),
                ),
                TableColumnSpec(
                  label: 'В профессии с',
                  build: (f) => Text('${f.experienceYear ?? "—"}'),
                ),
              ],
              actions: canEdit
                  ? (f) => [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Редактировать',
                        onPressed: () => context.go('/florists/${f.id}/edit'),
                      ),
                      if (!f.isDeleted)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Логически удалить',
                          onPressed: () => n.softDeleteOne(f.id),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.restore),
                          tooltip: 'Восстановить',
                          onPressed: () => n.restoreOne(f.id),
                        ),
                      if (auth.has(Role.admin))
                        IconButton(
                          icon: const Icon(Icons.delete_forever),
                          tooltip: 'Удалить насовсем',
                          onPressed: () => n.hardDeleteOne(f.id),
                        ),
                    ]
                  : null,
            ),
          ),
        );
    }
  }
}
