import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;
  final bool Function(T item)? isDeleted;
  final void Function(T item)? onRowTap;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
    this.isDeleted,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final sortIndex = _sortIndex;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          sortColumnIndex: sortIndex,
          sortAscending: sortAscending,
          columns: [
            for (final c in columns)
              DataColumn(
                label: Text(c.label),
                numeric: c.numeric,
                onSort: c.sortField != null && onSort != null
                    ? (_, __) => onSort!(c.sortField!)
                    : null,
              ),
            if (actions != null) const DataColumn(label: Text('')),
          ],
          rows: [
            for (final item in items)
              DataRow(
                selected: selected.contains(idOf(item)),
                color: isDeleted?.call(item) == true
                    ? WidgetStateProperty.all(
                        Colors.grey.withValues(alpha: 0.15),
                      )
                    : null,
                onSelectChanged: onToggleSelect == null
                    ? null
                    : (_) => onToggleSelect!(idOf(item)),
                cells: [
                  for (final c in columns)
                    DataCell(
                      InkWell(
                        onTap: onRowTap == null ? null : () => onRowTap!(item),
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: c.build(item),
                          ),
                        ),
                      ),
                    ),
                  if (actions != null)
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!(item),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  int? get _sortIndex {
    if (sortField == null) return null;
    for (var i = 0; i < columns.length; i++) {
      if (columns[i].sortField == sortField) return i;
    }
    return null;
  }
}
