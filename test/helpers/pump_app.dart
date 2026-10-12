import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Advances past async loads without hanging on infinite progress animations.
Future<void> pumpUntilSettled(WidgetTester tester) async {
  await tester.pump();
  // Always allow a few frames for microtasks / Duration.zero futures.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  for (var i = 0; i < 40; i++) {
    final loading = find.byType(CircularProgressIndicator);
    if (loading.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 16));
      return;
    }
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxAttempts = 40,
}) async {
  for (var i = 0; i < maxAttempts; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
}
