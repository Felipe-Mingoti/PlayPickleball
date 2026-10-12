import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:play_pickleball/app/app.dart';
import 'package:play_pickleball/app/router/app_router.dart';
import 'package:play_pickleball/features/paddles/view/providers/paddle_providers.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_paddles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp({required GoRouter router}) {
    return ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        paddleRepositoryProvider.overrideWithValue(FakePaddleRepository()),
      ],
      child: PlayPickleballApp(router: router),
    );
  }

  Finder catalogAppBarButton() => find.widgetWithText(TextButton, 'Catalog');
  Finder floatingCatalogIcon() => find.byIcon(Icons.grid_view_outlined);

  testWidgets('compact/medium shows floating nav and hides AppBar Catalog/Compare',
      (tester) async {
    // Medium width (< 900) avoids unrelated catalog filter overflow at phone sizes.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp(router: createAppRouter()));
    await pumpUntilSettled(tester);

    expect(catalogAppBarButton(), findsNothing);
    expect(find.widgetWithText(TextButton, 'Compare'), findsNothing);
    expect(floatingCatalogIcon(), findsOneWidget);
    expect(find.byIcon(Icons.compare_arrows), findsOneWidget);
  });

  testWidgets('expanded shows AppBar Catalog/Compare and hides floating nav',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp(router: createAppRouter()));
    await pumpUntilSettled(tester);

    expect(catalogAppBarButton(), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Compare'), findsOneWidget);
    expect(floatingCatalogIcon(), findsNothing);
  });
}
