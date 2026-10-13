import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_pickleball/app/app.dart';
import 'package:play_pickleball/app/router/app_router.dart';
import 'package:play_pickleball/app/theme/app_spacing.dart';
import 'package:play_pickleball/features/paddles/view/providers/paddle_providers.dart';
import 'package:play_pickleball/features/paddles/view/widgets/catalog_filter_options.dart';
import 'package:play_pickleball/features/paddles/view/widgets/catalog_sort_menu.dart';
import 'package:play_pickleball/features/paddles/view/widgets/paddle_card.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_paddles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp() {
    return ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        paddleRepositoryProvider.overrideWithValue(FakePaddleRepository()),
      ],
      child: PlayPickleballApp(router: createAppRouter()),
    );
  }

  Future<void> pumpCatalog(WidgetTester tester, {required Size size}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(buildApp());
    await pumpUntilSettled(tester);
  }

  void expectUnfilteredCatalog() {
    expect(find.text('Summit Pro 16'), findsOneWidget);
    expect(find.text('Soft Touch 16'), findsOneWidget);
    expect(find.text('Transition'), findsOneWidget);
  }

  void expectElongatedCatalog() {
    expect(find.text('Summit Pro 16'), findsOneWidget);
    expect(find.text('Soft Touch 16'), findsNothing);
    expect(find.text('Transition'), findsNothing);
  }

  double ledBlur(WidgetTester tester) {
    final glow = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(PaddleCard).first,
        matching: find.byWidgetPredicate((widget) {
          final decoration = widget is DecoratedBox ? widget.decoration : null;
          return decoration is BoxDecoration && decoration.boxShadow != null;
        }),
      ),
    );
    return (glow.decoration as BoxDecoration).boxShadow!.single.blurRadius;
  }

  testWidgets('mobile filter sheet applies on save and clears when reopened', (
    tester,
  ) async {
    await pumpCatalog(tester, size: const Size(400, 3200));

    expect(find.byTooltip('Filters'), findsOneWidget);
    final fieldSize = tester.getSize(find.byType(TextField));
    final buttonSize = tester.getSize(find.byTooltip('Filters'));
    expect(buttonSize.height, closeTo(fieldSize.height, 1));
    expect(buttonSize.width, closeTo(buttonSize.height, 1));
    final primary = Theme.of(tester.element(find.byType(TextField)))
        .colorScheme
        .primary;
    expect(tester.widget<Icon>(find.byIcon(Icons.search)).color, primary);
    expect(tester.widget<Icon>(find.byIcon(Icons.menu)).color, primary);
    expect(find.text('Shape'), findsNothing);
    expect(find.text('Sort: Name'), findsOneWidget);
    expect(ledBlur(tester), 10);
    expectUnfilteredCatalog();

    final sortBottom = tester.getRect(find.byType(CatalogSortMenu)).bottom;
    final cardTop = tester.getRect(find.byType(PaddleCard).first).top;
    expect(cardTop - sortBottom, closeTo(AppSpacing.lg, 1));

    await tester.tap(find.byTooltip('Filters'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Clear filters'), findsNothing);
    expect(find.text('Catalog').hitTestable(), findsNothing);
    expect(find.text('Compare').hitTestable(), findsNothing);
    expect(find.text('Save filters').hitTestable(), findsOneWidget);

    final elongated = find.widgetWithText(CatalogFilterOptionTile, 'Elongated');
    await tester.ensureVisible(elongated);
    await tester.tap(elongated);
    await tester.pump();
    expectUnfilteredCatalog();

    final save = find.text('Save filters');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Save filters'), findsNothing);
    expectElongatedCatalog();

    await tester.tap(find.byTooltip('Filters'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final clear = find.text('Clear filters');
    await tester.ensureVisible(clear);
    await tester.tap(clear);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Clear filters'), findsNothing);
    expectUnfilteredCatalog();
  });

  testWidgets('wide filter cards apply immediately and clear from a card', (
    tester,
  ) async {
    await pumpCatalog(tester, size: const Size(800, 2400));

    expect(find.byTooltip('Filters'), findsNothing);
    expect(find.text('Shape'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('In stock only'), findsOneWidget);
    expect(find.text('Clear filters'), findsNothing);
    expect(find.text('Sort: Name'), findsOneWidget);
    final shape = tester.getRect(find.text('Shape'));
    final sort = tester.getRect(find.text('Sort: Name'));
    expect(sort.left, greaterThan(shape.right));
    expect((sort.center.dy - shape.center.dy).abs(), lessThan(24));
    expect(ledBlur(tester), 10);
    expectUnfilteredCatalog();

    await tester.tap(find.text('Shape'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CatalogFilterOptionTile, 'Elongated'));
    await tester.pump();

    expectElongatedCatalog();
    expect(find.text('Shape · Elongated'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pump();

    expect(find.text('Clear filters'), findsNothing);
    expect(find.text('Shape · Elongated'), findsNothing);
    expect(find.text('Shape'), findsWidgets);
    expectUnfilteredCatalog();
  });

  int catalogCrossAxisCount(WidgetTester tester) {
    final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    return delegate.crossAxisCount;
  }

  testWidgets('catalog uses four columns from 1200px and three below that', (
    tester,
  ) async {
    await pumpCatalog(tester, size: const Size(1000, 1600));
    expect(catalogCrossAxisCount(tester), 3);

    await pumpCatalog(tester, size: const Size(1200, 1600));
    expect(catalogCrossAxisCount(tester), 4);
  });

  testWidgets('small phone catalog does not overflow', (tester) async {
    await pumpCatalog(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);
    expect(find.text('Paddle catalog'), findsOneWidget);
    final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 1);
    expect(delegate.childAspectRatio, 0.58);
  });
}
