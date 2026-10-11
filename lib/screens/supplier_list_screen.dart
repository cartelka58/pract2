import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/models.dart';
import '../state/auth_notifier.dart';
import '../state/notifiers.dart';
import '../widgets/entity_table.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});
  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierListNotifier>().load();
    });
  }

  Future<void> _deleteWithCheck(
    SupplierListNotifier n,
    int id, {
    required bool hard,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (hard) {
        await n.hardDelete(id);
      } else {
        await n.softDelete(id);
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<SupplierListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final width = MediaQuery.of(context).size.width;
    // Таблица влезает только от 800 px
    final isNarrow = width < 800;
    // Меню прячем на ширине < 600
    final hideActionsInMenu = width < 600;
    final rose = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping),
            SizedBox(width: 8),
            Text('Поставщики'),
          ],
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
                    value: '/suppliers/new',
                    child: Text('Добавить поставщика'),
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
                tooltip: 'Добавить',
                icon: const Icon(Icons.add),
                onPressed: () => context.go('/suppliers/new'),
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
            Expanded(child: _body(n, isNarrow, rose)),
          ],
        ),
      ),
    );
  }

  Widget _body(SupplierListNotifier n, bool narrow, Color rose) {
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

        final auth = context.watch<AuthNotifier>();
        final canEdit = auth.has(Role.florist);

        // На узком экране — карточки
        if (narrow) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: n.items.length,
            itemBuilder: (_, i) {
              final s = n.items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    s.name,
                    style: TextStyle(color: rose, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${s.phone} • ${s.city}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: canEdit
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                context.go('/suppliers/${s.id}/edit');
                                break;
                              case 'soft-delete':
                                _deleteWithCheck(n, s.id, hard: false);
                                break;
                              case 'restore':
                                n.restore(s.id);
                                break;
                              case 'hard-delete':
                                _deleteWithCheck(n, s.id, hard: true);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Редактировать'),
                            ),
                            if (!s.isDeleted)
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
                  onTap: () => context.go('/suppliers/${s.id}'),
                ),
              );
            },
          );
        }

        // На широком — таблица
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: EntityTable<Supplier>(
              items: n.items,
              idOf: (s) => s.id,
              onRowTap: (s) => context.go('/suppliers/${s.id}'),
              isDeleted: (s) => s.isDeleted,
              columns: [
                TableColumnSpec(
                  label: 'Название',
                  build: (s) => Text(s.name, overflow: TextOverflow.ellipsis),
                ),
                TableColumnSpec(label: 'Телефон', build: (s) => Text(s.phone)),
                TableColumnSpec(label: 'Город', build: (s) => Text(s.city)),
              ],
              actions: canEdit
                  ? (s) => [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Редактировать',
                        onPressed: () => context.go('/suppliers/${s.id}/edit'),
                      ),
                      if (!s.isDeleted)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Логически удалить',
                          onPressed: () =>
                              _deleteWithCheck(n, s.id, hard: false),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.restore),
                          tooltip: 'Восстановить',
                          onPressed: () => n.restore(s.id),
                        ),
                      if (auth.has(Role.admin))
                        IconButton(
                          icon: const Icon(Icons.delete_forever),
                          tooltip: 'Удалить насовсем',
                          onPressed: () =>
                              _deleteWithCheck(n, s.id, hard: true),
                        ),
                    ]
                  : null,
            ),
          ),
        );
    }
  }
}
