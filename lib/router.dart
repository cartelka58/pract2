import 'package:go_router/go_router.dart';
import 'screens/bouquet_list_screen.dart';
import 'screens/bouquet_detail_screen.dart';
import 'screens/florist_list_screen.dart';
import 'screens/florist_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const BouquetListScreen(),
      routes: [
        GoRoute(
          path: 'bouquets/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return BouquetDetailScreen(id: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/bouquets/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return BouquetDetailScreen(id: id);
      },
    ),
    GoRoute(path: '/florists', builder: (_, __) => const FloristListScreen()),
    GoRoute(
      path: '/florists/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return FloristDetailScreen(id: id);
      },
    ),
  ],
);
