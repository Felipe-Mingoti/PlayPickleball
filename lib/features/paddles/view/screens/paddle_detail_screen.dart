import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../common/extensions/context_extensions.dart';
import '../../../../common/layouts/detail_page_layout.dart';
import '../../../../common/widgets/buttons/app_button.dart';
import '../../../../common/widgets/feedback/app_empty_state.dart';
import '../../../../common/widgets/feedback/app_error_state.dart';
import '../../../../common/widgets/feedback/app_loading_state.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/paddle.dart';
import '../../domain/value_objects/comparison_selection.dart';
import '../providers/comparison_providers.dart';
import '../providers/paddle_providers.dart';
import '../widgets/hero_namespace.dart';
import '../widgets/paddle_hero_image.dart';
import '../widgets/paddle_image_viewer.dart';
import '../widgets/paddle_specs.dart';
import '../widgets/similar_paddles_carousel.dart';

class PaddleDetailScreen extends ConsumerWidget {
  const PaddleDetailScreen({super.key, required this.paddleId});

  final String paddleId;

  void _showLimitMessage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warning = Theme.of(context).extension<AppSemanticColors>()?.warning;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You can compare up to 3 paddles. Remove one to add another.',
          style: TextStyle(
            color: isDark ? AppColors.darkOnSecondary : Colors.white,
          ),
        ),
        backgroundColor: warning,
      ),
    );
  }

  void _toggleCompare(
    BuildContext context,
    ComparisonSelection selection,
    String id,
  ) {
    if (selection.contains(id)) {
      context.router.replaceSelection(selection.remove(id));
      return;
    }
    final result = selection.add(id);
    if (result.result == ComparisonAddResult.limitReached) {
      _showLimitMessage(context);
      return;
    }
    context.router.replaceSelection(result.selection);
  }

  Paddle? _find(List<Paddle> paddles) {
    for (final paddle in paddles) {
      if (paddle.id == paddleId) return paddle;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = selectionFromContext(context);
    final paddlesAsync = ref.watch(paddlesProvider);
    final heroExtra = GoRouterState.of(context).extra;
    final heroNamespace =
        heroExtra is PaddleHeroExtra ? heroExtra.namespace : null;

    return paddlesAsync.when(
      loading: () => const AppLoadingState(),
      error: (error, _) => AppErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(paddlesProvider),
      ),
      data: (paddles) {
        final match = _find(paddles);
        if (match == null) {
          return AppEmptyState(
            title: 'Paddle not found',
            message: 'This paddle is unavailable or the link is invalid.',
            actionLabel: 'Back to catalog',
            onAction: () => context.router.goCatalog(selection: selection),
            icon: Icons.search_off,
          );
        }

        final selected = selection.contains(match.id);

        final photoPath = match.imagePath;

        return DetailPageLayout(
          image: photoPath == null
              ? PaddleHeroImage(
                  paddle: match,
                  heroNamespace: heroNamespace,
                )
              : MergeSemantics(
                  child: Semantics(
                    button: true,
                    label: 'View larger photo',
                    onTap: () => showPaddleImageViewer(context, photoPath),
                    child: GestureDetector(
                      onTap: () => showPaddleImageViewer(context, photoPath),
                      child: ExcludeSemantics(
                        child: PaddleHeroImage(
                          paddle: match,
                          heroNamespace: heroNamespace,
                        ),
                      ),
                    ),
                  ),
                ),
          summary: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.brand,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                match.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                Formatters.priceUsd(match.priceUsd),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.colors.primary,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              PaddleKeySpecs(paddle: match),
              if (match.description.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  match.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ],
          ),
          actions: AppButton(
            label: selected ? 'Remove from compare' : 'Add to compare',
            icon: selected ? Icons.check_circle : Icons.add,
            expanded: true,
            variant:
                selected ? AppButtonVariant.tonal : AppButtonVariant.primary,
            onPressed: () => _toggleCompare(context, selection, match.id),
          ),
          details: PaddleSpecs(paddle: match),
          additionalContent: SimilarPaddlesCarousel(
            paddleId: match.id,
            selection: selection,
            onLimitReached: () => _showLimitMessage(context),
            onToggleCompare: (id) => _toggleCompare(context, selection, id),
          ),
        );
      },
    );
  }
}

extension on BuildContext {
  GoRouter get router => GoRouter.of(this);
}
