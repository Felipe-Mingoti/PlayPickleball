import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:play_pickleball/app/app.dart';
import 'package:play_pickleball/app/router/app_router.dart';
import 'package:play_pickleball/core/errors/data_load_failure.dart';
import 'package:play_pickleball/features/paddles/data/datasources/paddle_mock_datasource.dart';
import 'package:play_pickleball/features/paddles/view/providers/paddle_providers.dart';
import 'package:play_pickleball/features/paddles/view/widgets/comparison_table.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_paddles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp({
    required GoRouter router,
    required FakePaddleRepository repository,
  }) {
    return ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        paddleRepositoryProvider.overrideWithValue(repository),
      ],
      child: PlayPickleballApp(router: router),
    );
  }

  testWidgets('catalog shows paddles', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createAppRouter();
    await tester.pumpWidget(
      buildApp(router: router, repository: FakePaddleRepository()),
    );
    await pumpUntilSettled(tester);
    expect(find.text('Paddle catalog'), findsOneWidget);
    await tester.ensureVisible(find.text('Add to compare').first);
    await pumpUntilSettled(tester);
    expect(find.text('Add to compare'), findsWidgets);
  });

  testWidgets('catalog error state can retry', (tester) async {
    final repository = FakePaddleRepository(failOnce: true);
    final router = createAppRouter();
    await tester.pumpWidget(
      buildApp(router: router, repository: repository),
    );
    await pumpUntilSettled(tester);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await pumpUntilSettled(tester);
    expect(find.text('Paddle catalog'), findsOneWidget);
  });

  testWidgets('compare selection feedback and limit message', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createAppRouter();
    await tester.pumpWidget(
      buildApp(router: router, repository: FakePaddleRepository()),
    );
    await pumpUntilSettled(tester);
    expect(find.text('Add to compare'), findsWidgets);

    Future<void> addNext() async {
      final button = find.text('Add to compare').first;
      await tester.ensureVisible(button);
      await tester.tap(button);
      await pumpUntilSettled(tester);
    }

    await addNext();
    expect(find.textContaining('1 of 3 selected'), findsOneWidget);
    await addNext();
    expect(find.textContaining('2 of 3 selected'), findsOneWidget);
    await addNext();
    expect(find.textContaining('3 of 3 selected'), findsOneWidget);
    await addNext();
    expect(
      find.textContaining('You can compare up to 3 paddles'),
      findsOneWidget,
    );
  });

  testWidgets('comparison table supports 375px layout and remove',
      (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createAppRouter(
      initialLocation:
          '/compare?ids=apex-court-summit-pro-16,dinkworks-soft-touch-16,erne-athletics-airborne-14',
    );
    await tester.pumpWidget(
      buildApp(router: router, repository: FakePaddleRepository()),
    );
    await pumpUntilSettled(tester);

    expect(find.byType(ComparisonTable), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Swipe sideways to see more paddles'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from compare').first);
    await pumpUntilSettled(tester);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['ids']!
          .split(',')
          .length,
      2,
    );
  });

  testWidgets('forced data failure type is DataLoadFailure', (tester) async {
    final source = PaddleMockDataSource(
      latency: Duration.zero,
      shouldFail: () => true,
    );
    await expectLater(source.fetchPaddles(), throwsA(isA<DataLoadFailure>()));
  });
}
