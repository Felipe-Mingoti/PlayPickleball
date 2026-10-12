import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// Consistent page chrome with optional bottom bar and constrained body.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.body,
    this.bottomBar,
    this.floatingActionButton,
    this.centerBody = true,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? body;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final bool centerBody;

  @override
  Widget build(BuildContext context) {
    final content = body == null
        ? null
        : centerBody
            ? Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.contentMaxWidth,
                  ),
                  child: body,
                ),
              )
            : body;

    return Scaffold(
      appBar: title == null && actions == null && leading == null
          ? null
          : AppBar(
              title: title,
              actions: actions,
              leading: leading,
              automaticallyImplyLeading: leading == null,
            ),
      body: content,
      bottomNavigationBar: bottomBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
