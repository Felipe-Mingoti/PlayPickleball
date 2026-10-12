import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/paddles/view/screens/catalog_screen.dart';
import '../../features/paddles/view/screens/paddle_compare_screen.dart';
import '../../features/paddles/view/screens/paddle_detail_screen.dart';
import '../shell/app_shell.dart';
import 'app_routes.dart';
import 'route_paths.dart';

GoRouter createAppRouter({
  GlobalKey<NavigatorState>? navigatorKey,
  String initialLocation = RoutePaths.paddles,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: RoutePaths.root,
        redirect: (_, _) => RoutePaths.paddles,
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.paddles,
            name: AppRoutes.paddles,
            builder: (context, state) => const CatalogScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: AppRoutes.paddleDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PaddleDetailScreen(paddleId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.compare,
            name: AppRoutes.compare,
            builder: (context, state) => const PaddleCompareScreen(),
          ),
        ],
      ),
    ],
  );
}
