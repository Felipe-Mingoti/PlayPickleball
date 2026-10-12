import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_controller.dart';

class PlayPickleballApp extends ConsumerStatefulWidget {
  const PlayPickleballApp({super.key, this.router});

  final GoRouter? router;

  @override
  ConsumerState<PlayPickleballApp> createState() => _PlayPickleballAppState();
}

class _PlayPickleballAppState extends ConsumerState<PlayPickleballApp> {
  late final GoRouter _router = widget.router ?? createAppRouter();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'PlayPickleball',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
