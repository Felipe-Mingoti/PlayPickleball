import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:play_pickleball/app/app.dart';
import 'package:play_pickleball/app/router/app_router.dart';
import 'package:play_pickleball/features/paddles/view/providers/paddle_providers.dart';
import 'package:play_pickleball/features/paddles/view/screens/catalog_screen.dart';
import 'package:play_pickleball/features/paddles/view/screens/paddle_compare_screen.dart';
import 'package:play_pickleball/features/paddles/view/screens/paddle_detail_screen.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_paddles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp(GoRouter router, {FakePaddleRepository? repository}) {
    return ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        paddleRepositoryProvider.overrideWithValue(
          repository ?? FakePaddleRepository(),
        ),
      ],
      child: PlayPickleballApp(router: router),
    );
  }

  testWidgets('opens a direct detail URL', (tester) async {
    final router = createAppRouter(
      initialLocation: '/paddles/apex-court-summit-pro-16',
    );
    await tester.pumpWidget(buildApp(router));
    await pumpUntilSettled(tester);
    expect(find.byType(PaddleDetailScreen), findsOneWidget);
    expect(find.text('Summit Pro 16'), findsWidgets);
  });

  testWidgets('opens a direct comparison URL', (tester) async {
    final router = createAppRouter(
      initialLocation:
          '/compare?ids=apex-court-summit-pro-16,dinkworks-soft-touch-16',
    );
    await tester.pumpWidget(buildApp(router));
    await pumpUntilSettled(tester);
    expect(find.byType(PaddleCompareScreen), findsOneWidget);
    expect(find.text('Compare paddles'), findsOneWidget);
    expect(find.textContaining('Summit Pro 16'), findsWidgets);
    expect(find.textContaining('Soft Touch 16'), findsWidgets);
  });

  testWidgets('keeps ids when navigating to catalog', (tester) async {
    final router = createAppRouter(
      initialLocation:
          '/compare?ids=apex-court-summit-pro-16,dinkworks-soft-touch-16',
    );
    await tester.pumpWidget(buildApp(router));
    await pumpUntilSettled(tester);

    await tester.tap(find.text('Catalog').first);
    await pumpUntilSettled(tester);

    expect(find.byType(CatalogScreen), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['ids'],
      'apex-court-summit-pro-16,dinkworks-soft-touch-16',
    );
  });

  testWidgets('unknown detail id shows not found', (tester) async {
    final router = createAppRouter(
      initialLocation: '/paddles/does-not-exist',
    );
    await tester.pumpWidget(buildApp(router));
    await pumpUntilSettled(tester);
    expect(find.text('Paddle not found'), findsOneWidget);
  });
}
