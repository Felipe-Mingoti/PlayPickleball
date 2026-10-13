import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../common/extensions/context_extensions.dart';
import '../../../../common/widgets/branding/app_footer.dart';
import '../../../../common/widgets/feedback/app_empty_state.dart';
import '../../../../common/widgets/feedback/app_error_state.dart';
import '../../../../common/widgets/feedback/app_loading_state.dart';
import '../../domain/usecases/compare_paddles_usecase.dart';
import '../providers/comparison_providers.dart';
import '../providers/paddle_providers.dart';
import '../widgets/comparison_table.dart';

class PaddleCompareScreen extends ConsumerStatefulWidget {
  const PaddleCompareScreen({super.key});

  @override
  ConsumerState<PaddleCompareScreen> createState() =>
      _PaddleCompareScreenState();
}

class _PaddleCompareScreenState extends ConsumerState<PaddleCompareScreen> {
  static const _maxPins = 5;

  var _highlightDifferences = true;
  final List<ComparisonAttribute> _pinned = [];

  void _showPinLimitMessage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warning = Theme.of(context).extension<AppSemanticColors>()?.warning;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You can pin up to 5 characteristics. Remove one to add another.',
          style: TextStyle(
            color: isDark ? AppColors.darkOnSecondary : Colors.white,
          ),
        ),
        backgroundColor: warning,
      ),
    );
  }

  void _togglePin(ComparisonAttribute attribute) {
    if (_pinned.contains(attribute)) {
      setState(() => _pinned.remove(attribute));
      return;
    }
    if (_pinned.length >= _maxPins) {
      _showPinLimitMessage();
      return;
    }
    setState(() => _pinned.add(attribute));
  }

  @override
  Widget build(BuildContext context) {
    final selection = selectionFromContext(context);
    final resultAsync = ref.watch(comparisonResultProvider(selection));

    return resultAsync.when(
      loading: () => const AppLoadingState(message: 'Loading comparison…'),
      error: (error, _) => AppErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(paddlesProvider),
      ),
      data: (result) {
        if (selection.isEmpty) {
          return AppEmptyState(
            title: 'No paddles selected yet.',
            message: 'Choose at least two paddles to start comparing.',
            actionLabel: 'Browse catalog',
            onAction: () => context.router.goCatalog(selection: selection),
            icon: Icons.compare_arrows,
          );
        }

        if (result.paddles.length < 2) {
          final message = selection.count == 1
              ? 'Choose at least two paddles to start comparing.'
              : result.hasUnknownIds
              ? 'One of the selected paddles is no longer available.'
              : 'Choose at least two paddles to start comparing.';
          return AppEmptyState(
            title: selection.count == 1
                ? 'Almost ready'
                : 'Comparison unavailable',
            message: message,
            actionLabel: 'Browse catalog',
            onAction: () => context.router.goCatalog(selection: selection),
            icon: Icons.add_circle_outline,
          );
        }

        return ListView(
          children: [
            Padding(
              padding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compare paddles',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Products are columns. Specifications are rows.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilterChip(
                        label: const Text('Highlight differences'),
                        selected: _highlightDifferences,
                        onSelected: (value) {
                          setState(() => _highlightDifferences = value);
                        },
                      ),
                    ],
                  ),
                  if (result.hasUnknownIds) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Material(
                      color: context.colors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'One of the selected paddles is no longer available.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: context.colors.onErrorContainer,
                              ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  ComparisonTable(
                    result: result,
                    selection: selection,
                    highlightDifferences: _highlightDifferences,
                    pinnedAttributes: _pinned,
                    onTogglePin: _togglePin,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
            const AppFooter(),
          ],
        );
      },
    );
  }
}

extension on BuildContext {
  GoRouter get router => GoRouter.of(this);
}
