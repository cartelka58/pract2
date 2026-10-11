import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/auth_notifier.dart';
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
    final auth = context.watch<AuthNotifier>();
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 800;
    final hideActionsInMenu = width < 600;
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
                    value: '/customers/new',
                    child: Text('Добавить покупателя'),
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
                onPressed: () => context.go('/customers/new'),
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

  Widget _body(CustomerListNotifier n, bool narrow, Color rose) {
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

        if (narrow) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: n.items.length,
            itemBuilder: (_, i) {
              final c = n.items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    c.fullName,
                    style: TextStyle(color: rose, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${c.email} • ${c.phone}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => context.go('/customers/${c.id}'),
                  trailing: canEdit
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                context.go('/customers/${c.id}/edit');
                                break;
                              case 'soft-delete':
                                n.softDelete(c.id);
                                break;
                              case 'restore':
                                n.restore(c.id);
                                break;
                              case 'hard-delete':
                                n.hardDelete(c.id);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Редактировать'),
                            ),
                            if (!c.isDeleted)
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
            ),
            child: EntityTable<Customer>(
              items: n.items,
              idOf: (c) => c.id,
              onRowTap: (c) => context.go('/customers/${c.id}'),
              isDeleted: (c) => c.isDeleted,
              columns: [
                TableColumnSpec(
                  label: 'Фамилия',
                  build: (c) =>
                      Text(c.lastName, overflow: TextOverflow.ellipsis),
                ),
                TableColumnSpec(
                  label: 'Имя',
                  build: (c) =>
                      Text(c.firstName, overflow: TextOverflow.ellipsis),
                ),
                TableColumnSpec(
                  label: 'Email',
                  build: (c) => Text(c.email, overflow: TextOverflow.ellipsis),
                ),
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
              actions: canEdit
                  ? (c) => [
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
                      if (auth.has(Role.admin))
                        IconButton(
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () => n.hardDelete(c.id),
                        ),
                    ]
                  : null,
            ),
          ),
        );
    }
  }
}
