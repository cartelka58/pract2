import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'repositories/api_bouquet_repository.dart';
import 'repositories/api_category_repository.dart';
import 'repositories/api_customer_repository.dart';
import 'repositories/api_florist_repository.dart';
import 'repositories/api_supplier_repository.dart';
import 'repositories/repositories.dart';
import 'router.dart';
import 'state/notifiers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>(create: (_) => buildDio()),

        Provider<BouquetRepository>(
          create: (ctx) => ApiBouquetRepository(ctx.read<Dio>()),
        ),
        Provider<FloristRepository>(
          create: (ctx) => ApiFloristRepository(ctx.read<Dio>()),
        ),
        Provider<CategoryRepository>(
          create: (ctx) => ApiCategoryRepository(ctx.read<Dio>()),
        ),
        Provider<SupplierRepository>(
          create: (ctx) => ApiSupplierRepository(ctx.read<Dio>()),
        ),
        Provider<CustomerRepository>(
          create: (ctx) => ApiCustomerRepository(ctx.read<Dio>()),
        ),

        // Состояние
        ChangeNotifierProvider(
          create: (ctx) => BouquetListNotifier(ctx.read<BouquetRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => FloristListNotifier(ctx.read<FloristRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CategoryListNotifier(ctx.read<CategoryRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SupplierListNotifier(ctx.read<SupplierRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CustomerListNotifier(ctx.read<CustomerRepository>()),
        ),
      ],
      child: const FlowerShopApp(),
    ),
  );
}

class FlowerShopApp extends StatelessWidget {
  const FlowerShopApp({super.key});

  static const _rose = Color(0xFFD81B60);
  static const _lavender = Color(0xFF9575CD);
  static const _leaf = Color(0xFF66BB6A);
  static const _cream = Color(0xFFFFF8E1);

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _rose,
      brightness: Brightness.light,
      primary: _rose,
      secondary: _lavender,
      tertiary: _leaf,
      surface: _cream,
    );

    return MaterialApp.router(
      title: 'Цветочный магазин',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: _cream,
        appBarTheme: AppBarTheme(
          backgroundColor: _rose,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _rose,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _lavender.withValues(alpha: 0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _lavender.withValues(alpha: 0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _rose, width: 2),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: _lavender.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(
            _lavender.withValues(alpha: 0.15),
          ),
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: _rose,
          ),
          dataRowColor: WidgetStateProperty.all(Colors.white),
          dividerThickness: 0.5,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _rose;
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        iconTheme: IconThemeData(color: _rose),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _rose;
            return _lavender.withValues(alpha: 0.3);
          }),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
