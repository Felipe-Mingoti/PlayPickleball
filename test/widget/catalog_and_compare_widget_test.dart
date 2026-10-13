import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:play_pickleball/app/app.dart';
import 'package:play_pickleball/app/router/app_router.dart';
import 'package:play_pickleball/core/errors/data_load_failure.dart';
import 'package:play_pickleball/features/paddles/data/datasources/paddle_mock_datasource.dart';
import 'package:play_pickleball/features/paddles/view/providers/paddle_providers.dart';
import 'package:play_pickleball/features/paddles/view/widgets/comparison_product_header.dart';
import 'package:play_pickleball/features/paddles/view/widgets/comparison_table.dart';
import 'package:play_pickleball/features/paddles/view/widgets/paddle_hero_image.dart';

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
      overrides: [paddleRepositoryProvider.overrideWithValue(repository)],
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
    await tester.pumpWidget(buildApp(router: router, repository: repository));
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

  testWidgets('comparison table supports 375px layout and remove', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createAppRouter(
      initialLocation: '/compare?ids=apex-court-summit-pro-16,dinkworks-soft-touch-16,erne-athletics-airborne-14',
    );
    await tester.pumpWidget(
      buildApp(router: router, repository: FakePaddleRepository()),
    );
    await pumpUntilSettled(tester);

    expect(find.byType(ComparisonTable), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Your picks'), findsOneWidget);
    expect(find.text('Swipe sideways to see more paddles'), findsOneWidget);
    expect(find.textContaining('of 3 selected'), findsNothing);

    await tester.tap(find.byTooltip('Remove from compare').first);
    await pumpUntilSettled(tester);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['ids']!
          .split(',')
          .length,
      2,
    );
  });

  testWidgets('pinning moves a row into Your picks and stops at five', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createAppRouter(
      initialLocation:
          '/compare?ids=apex-court-summit-pro-16,dinkworks-soft-touch-16',
    );
    await tester.pumpWidget(
      buildApp(router: router, repository: FakePaddleRepository()),
    );
    await pumpUntilSettled(tester);

    Future<void> pin(String label) async {
      await tester.tap(find.text(label));
      await pumpUntilSettled(tester);
    }

    await pin('Price');
    expect(find.text('Price'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Price')).dy,
      greaterThan(tester.getTopLeft(find.text('Your picks')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Price')).dy,
      lessThan(tester.getTopLeft(find.text('General')).dy),
    );

    await pin('Price');
    expect(
      tester.getTopLeft(find.text('Price')).dy,
      greaterThan(tester.getTopLeft(find.text('General')).dy),
    );

    await pin('Price');
    await pin('Shape');
    await pin('Release year');
    await pin('Availability');
    await pin('Length');
    expect(find.byIcon(Icons.push_pin), findsNWidgets(5));

    await pin('Width');
    expect(
      find.textContaining(
        'You can pin up to 5 characteristics. Remove one to add another.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.push_pin), findsNWidgets(5));
    expect(
      tester.getTopLeft(find.text('Width')).dy,
      greaterThan(tester.getTopLeft(find.text('Dimensions')).dy),
    );
  });

  testWidgets('sideways drag on a paddle card scrolls the comparison', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createAppRouter(
      initialLocation: '/compare?ids=apex-court-summit-pro-16,dinkworks-soft-touch-16,erne-athletics-airborne-14',
    );
    await tester.pumpWidget(
      buildApp(router: router, repository: FakePaddleRepository()),
    );
    await pumpUntilSettled(tester);

    final image = find.byType(PaddleHeroImage).first;
    await tester.ensureVisible(image);
    await tester.drag(image, const Offset(-160, 0));
    await tester.pumpAndSettle();

    final offsets = <double>[
      for (final state in tester.stateList<ScrollableState>(
        find.byType(Scrollable),
      ))
        if (state.position.axis == Axis.horizontal &&
            state.position.maxScrollExtent > 8)
          state.position.pixels,
    ];
    expect(offsets, isNotEmpty);
    expect(offsets.first, greaterThan(20));
    for (final offset in offsets) {
      expect(offset, closeTo(offsets.first, 2));
    }
  });

  testWidgets('wide compare columns fill the card up to 420px', (tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createAppRouter(
      initialLocation: '/compare?ids=apex-court-summit-pro-16,dinkworks-soft-touch-16,erne-athletics-airborne-14',
    );
    await tester.pumpWidget(
      buildApp(router: router, repository: FakePaddleRepository()),
    );
    await pumpUntilSettled(tester);

    final width = tester
        .getSize(find.byType(ComparisonProductHeader).first)
        .width;
    expect(width, greaterThan(220));
    expect(width, lessThanOrEqualTo(420));
  });

  testWidgets('forced data failure type is DataLoadFailure', (tester) async {
    final source = PaddleMockDataSource(
      latency: Duration.zero,
      shouldFail: () => true,
    );
    await expectLater(source.fetchPaddles(), throwsA(isA<DataLoadFailure>()));
  });
}
