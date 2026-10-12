import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.message = 'Loading paddles…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.lg),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
