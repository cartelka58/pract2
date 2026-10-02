import 'package:go_router/go_router.dart';
import 'screens/bouquet_list_screen.dart';
import 'screens/bouquet_detail_screen.dart';
import 'screens/bouquet_form_screen.dart';
import 'screens/florist_list_screen.dart';
import 'screens/florist_detail_screen.dart';
import 'screens/florist_form_screen.dart';
import 'screens/category_list_screen.dart';
import 'screens/category_detail_screen.dart';
import 'screens/category_form_screen.dart';
import 'screens/supplier_list_screen.dart';
import 'screens/supplier_detail_screen.dart';
import 'screens/supplier_form_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/customer_detail_screen.dart';
import 'screens/customer_form_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const BouquetListScreen()),
    GoRoute(
      path: '/bouquets/new',
      builder: (_, __) => const BouquetFormScreen(),
    ),
    GoRoute(
      path: '/bouquets/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return BouquetDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/bouquets/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return BouquetFormScreen(id: id);
      },
    ),
    GoRoute(path: '/florists', builder: (_, __) => const FloristListScreen()),
    GoRoute(
      path: '/florists/new',
      builder: (_, __) => const FloristFormScreen(),
    ),
    GoRoute(
      path: '/florists/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return FloristDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/florists/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return FloristFormScreen(id: id);
      },
    ),
    GoRoute(
      path: '/categories',
      builder: (_, __) => const CategoryListScreen(),
    ),
    GoRoute(
      path: '/categories/new',
      builder: (_, __) => const CategoryFormScreen(),
    ),
    GoRoute(
      path: '/categories/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return CategoryDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/categories/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return CategoryFormScreen(id: id);
      },
    ),
    GoRoute(path: '/suppliers', builder: (_, __) => const SupplierListScreen()),
    GoRoute(
      path: '/suppliers/new',
      builder: (_, __) => const SupplierFormScreen(),
    ),
    GoRoute(
      path: '/suppliers/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return SupplierDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/suppliers/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return SupplierFormScreen(id: id);
      },
    ),
    GoRoute(path: '/customers', builder: (_, __) => const CustomerListScreen()),
    GoRoute(
      path: '/customers/new',
      builder: (_, __) => const CustomerFormScreen(),
    ),
    GoRoute(
      path: '/customers/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return CustomerDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/customers/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return CustomerFormScreen(id: id);
      },
    ),
  ],
);
