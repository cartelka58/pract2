import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:library_web/widgets/paginator.dart';

void main() {
  // Обёртка для тестирования виджета в MaterialApp + Scaffold
  Widget wrap(Widget child) => MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E63)),
        ),
        home: Scaffold(body: child),
      );

  group('Paginator', () {
    testWidgets('отображает общее количество записей', (tester) async {
      await tester.pumpWidget(wrap(Paginator(
        page: 1,
        totalPages: 5,
        total: 42,
        size: 10,
        onPage: (_) {},
        onSize: (_) {},
      )));

      expect(find.text('Всего: 42'), findsOneWidget);
      expect(find.text('Стр. 1 / 5'), findsOneWidget);
    });

    testWidgets('кнопки «назад» отключены на первой странице', (tester) async {
      await tester.pumpWidget(wrap(Paginator(
        page: 1,
        totalPages: 5,
        total: 42,
        size: 10,
        onPage: (_) {},
        onSize: (_) {},
      )));

      final first = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.first_page),
      );
      final prev = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(first.onPressed, isNull);
      expect(prev.onPressed, isNull);

      final next = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(next.onPressed, isNotNull);
    });

    testWidgets('кнопки «вперёд» отключены на последней странице',
        (tester) async {
      await tester.pumpWidget(wrap(Paginator(
        page: 5,
        totalPages: 5,
        total: 42,
        size: 10,
        onPage: (_) {},
        onSize: (_) {},
      )));

      final next = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      final last = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.last_page),
      );
      expect(next.onPressed, isNull);
      expect(last.onPressed, isNull);

      final prev = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(prev.onPressed, isNotNull);
    });

    testWidgets('нажатие «вперёд» вызывает onPage со следующей страницей',
        (tester) async {
      int? tapped;
      await tester.pumpWidget(wrap(Paginator(
        page: 3,
        totalPages: 5,
        total: 42,
        size: 10,
        onPage: (p) => tapped = p,
        onSize: (_) {},
      )));

      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await tester.pump();

      expect(tapped, 4);
    });

    testWidgets('нажатие «в начало» вызывает onPage(1)', (tester) async {
      int? tapped;
      await tester.pumpWidget(wrap(Paginator(
        page: 4,
        totalPages: 5,
        total: 42,
        size: 10,
        onPage: (p) => tapped = p,
        onSize: (_) {},
      )));

      await tester.tap(find.widgetWithIcon(IconButton, Icons.first_page));
      await tester.pump();

      expect(tapped, 1);
    });

    testWidgets('DropdownButton показывает текущий size', (tester) async {
      await tester.pumpWidget(wrap(Paginator(
        page: 1,
        totalPages: 5,
        total: 42,
        size: 25,
        onPage: (_) {},
        onSize: (_) {},
      )));

      final dd = tester.widget<DropdownButton<int>>(
        find.byType(DropdownButton<int>),
      );
      expect(dd.value, 25);
    });

    testWidgets('изменение size вызывает onSize', (tester) async {
      int? newSize;
      await tester.pumpWidget(wrap(Paginator(
        page: 1,
        totalPages: 5,
        total: 42,
        size: 10,
        onPage: (_) {},
        onSize: (s) => newSize = s,
      )));

      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('25').last);
      await tester.pumpAndSettle();

      expect(newSize, 25);
    });
  });
}