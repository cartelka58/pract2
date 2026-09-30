import 'package:flutter/material.dart';

class Paginator extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final int size;
  final void Function(int page) onPage;
  final void Function(int size) onSize;

  const Paginator({
    super.key,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.size,
    required this.onPage,
    required this.onSize,
  });

  @override
  Widget build(BuildContext context) {
    final rose = Theme.of(context).colorScheme.primary;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(Icons.local_florist, color: rose, size: 20),
          const SizedBox(width: 4),
          Text(
            'Всего: $total',
            style: TextStyle(color: rose, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.first_page),
            color: rose,
            onPressed: page > 1 ? () => onPage(1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: rose,
            onPressed: page > 1 ? () => onPage(page - 1) : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: rose.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Стр. $page / $totalPages',
              style: TextStyle(color: rose, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: rose,
            onPressed: page < totalPages ? () => onPage(page + 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            color: rose,
            onPressed: page < totalPages ? () => onPage(totalPages) : null,
          ),
          const SizedBox(width: 16),
          const Text('На странице:'),
          const SizedBox(width: 6),
          DropdownButton<int>(
            value: size,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 10, child: Text('10')),
              DropdownMenuItem(value: 25, child: Text('25')),
              DropdownMenuItem(value: 50, child: Text('50')),
            ],
            onChanged: (v) => v != null ? onSize(v) : null,
          ),
        ],
      ),
    );
  }
}
