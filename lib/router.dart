import 'package:go_router/go_router.dart';

import 'models/models.dart';
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
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forbidden_screen.dart';
import 'state/auth_notifier.dart';

/// Публичные маршруты — доступны без входа.
const _publicPaths = <String>{'/login', '/register', '/forbidden'};

/// Пути, требующие роли не ниже «флорист».
const _floristPaths = <String>{
  '/bouquets/new',
  '/florists',
  '/florists/new',
  '/categories',
  '/categories/new',
  '/suppliers',
  '/suppliers/new',
  '/customers',
  '/customers/new',
};

GoRouter buildRouter(AuthNotifier auth) {
  return GoRouter(
    // Маршрутизатор пересчитает redirect при каждом изменении авторизации
    refreshListenable: auth,
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final path = state.matchedLocation;
      final isPublic = _publicPaths.contains(path);

      // 1. Не вошёл и идёт на закрытый экран → на /login с from
      if (!loggedIn && !isPublic) {
        return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
      }

      // 2. Уже вошёл и идёт на /login или /register → на главную
      if (loggedIn && (path == '/login' || path == '/register')) {
        return '/';
      }

      // 3. Требуется роль не ниже «флорист»
      if (_floristPaths.contains(path) && !auth.has(Role.florist)) {
        return '/forbidden';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          return LoginScreen(from: from);
        },
      ),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forbidden', builder: (_, __) => const ForbiddenScreen()),

      // Главная — доступна всем вошедшим
      GoRoute(path: '/', builder: (_, __) => const BouquetListScreen()),

      // Букеты
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
        redirect: (context, state) =>
            auth.has(Role.florist) ? null : '/forbidden',
      ),

      // Флористы
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
        redirect: (context, state) =>
            auth.has(Role.florist) ? null : '/forbidden',
      ),

      // Категории
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
        redirect: (context, state) =>
            auth.has(Role.florist) ? null : '/forbidden',
      ),

      // Поставщики
      GoRoute(
        path: '/suppliers',
        builder: (_, __) => const SupplierListScreen(),
      ),
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
        redirect: (context, state) =>
            auth.has(Role.florist) ? null : '/forbidden',
      ),

      // Покупатели
      GoRoute(
        path: '/customers',
        builder: (_, __) => const CustomerListScreen(),
      ),
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
        redirect: (context, state) =>
            auth.has(Role.florist) ? null : '/forbidden',
      ),
    ],
  );
}
