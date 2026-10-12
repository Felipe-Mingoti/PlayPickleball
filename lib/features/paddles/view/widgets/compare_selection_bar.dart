import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../common/extensions/context_extensions.dart';
import '../../../../common/widgets/buttons/app_button.dart';
import '../../../../common/widgets/images/app_image_placeholder.dart';
import '../../domain/entities/paddle.dart';
import '../../domain/value_objects/comparison_selection.dart';
import '../providers/comparison_providers.dart';
import '../providers/paddle_providers.dart';

class CompareSelectionBar extends ConsumerWidget {
  const CompareSelectionBar({
    super.key,
    required this.selection,
    this.applyBottomSafeArea = true,
  });

  final ComparisonSelection selection;

  /// When false, bottom inset is left to chrome below (e.g. floating nav).
  final bool applyBottomSafeArea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selection.isEmpty) return const SizedBox.shrink();

    final paddlesAsync = ref.watch(paddlesProvider);
    final colors = Theme.of(context).colorScheme;
    final surface = context.semanticColors.surfaceVariant;

    return Material(
      elevation: 8,
      color: surface,
      child: SafeArea(
        top: false,
        bottom: applyBottomSafeArea,
        child: paddlesAsync.when(
          loading: () => const SizedBox(height: 72),
          error: (_, _) => const SizedBox.shrink(),
          data: (paddles) {
            final byId = {for (final p in paddles) p.id: p};
            final selected = <Paddle>[
              for (final id in selection.ids)
                if (byId[id] != null) byId[id]!,
            ];

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${selection.count} of ${ComparisonSelection.maxSelection} selected',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          selection.canCompare
                              ? 'Ready to compare'
                              : 'Add another paddle to compare',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: selected.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final paddle = selected[index];
                              return _Thumb(
                                paddle: paddle,
                                onRemove: () {
                                  context.router.replaceSelection(
                                    selection.remove(paddle.id),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  AppButton(
                    label: 'Compare',
                    icon: Icons.compare_arrows,
                    onPressed: selection.canCompare
                        ? () => context.router.goCompare(selection: selection)
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

extension on BuildContext {
  GoRouter get router => GoRouter.of(this);
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.paddle, required this.onRemove});

  final Paddle paddle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline),
            borderRadius: BorderRadius.circular(8),
            color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          child: paddle.imagePath == null
              ? const Padding(
                  padding: EdgeInsets.all(4),
                  child: AppImagePlaceholder(label: ''),
                )
              : Padding(
                  padding: const EdgeInsets.all(2),
                  child: Image.asset(
                    paddle.imagePath!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const AppImagePlaceholder(label: ''),
                  ),
                ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: IconButton(
            tooltip: 'Remove ${paddle.name}',
            onPressed: onRemove,
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              backgroundColor: colors.surface,
              foregroundColor: colors.onSurface,
              minimumSize: const Size(28, 28),
              padding: EdgeInsets.zero,
              side: BorderSide(color: colors.outline),
            ),
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}
