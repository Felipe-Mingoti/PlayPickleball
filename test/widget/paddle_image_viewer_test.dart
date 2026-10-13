import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_pickleball/features/paddles/view/widgets/paddle_image_viewer.dart';

void main() {
  const imagePath = 'assets/images/paddles/apex-court-summit-pro-16.png';

  TransformationController controllerOf(WidgetTester tester) {
    return tester
        .widget<InteractiveViewer>(find.byType(InteractiveViewer))
        .transformationController!;
  }

  Future<void> doubleTap(WidgetTester tester) async {
    final viewer = find.byType(InteractiveViewer);
    await tester.tap(viewer);
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(viewer);
    await tester.pump();
  }

  testWidgets('double tap zooms toward the tap, drag pans, and a second double tap resets', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PaddleImageViewer(imagePath: imagePath)),
    );
    await tester.pump();

    await doubleTap(tester);
    final controller = controllerOf(tester);
    expect(controller.value.getMaxScaleOnAxis(), 2.5);

    final zoomed = controller.value.clone();
    await tester.drag(find.byType(InteractiveViewer), const Offset(-30, -20));
    await tester.pump();
    expect(controller.value.getTranslation().x, isNot(zoomed.getTranslation().x));

    await doubleTap(tester);
    expect(controller.value.getMaxScaleOnAxis(), 1);
  });

  testWidgets('close returns to the page underneath', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showPaddleImageViewer(context, imagePath),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PaddleImageViewer), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PaddleImageViewer), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });
}
