import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      // Prefer explicit retry UI over silent automatic retries.
      retry: (retryCount, error) => null,
      child: const PlayPickleballApp(),
    ),
  );
}
