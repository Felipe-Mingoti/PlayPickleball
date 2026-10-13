import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../common/widgets/buttons/app_button.dart';
import '../../../../common/widgets/cards/app_card.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/paddle.dart';
import 'paddle_hero_image.dart';

class PaddleCard extends StatelessWidget {
  const PaddleCard({
    super.key,
    required this.paddle,
    required this.selected,
    required this.onOpen,
    required this.onToggleCompare,
    this.heroNamespace,
    this.compact = false,
  });

  final Paddle paddle;
  final bool selected;
  final VoidCallback onOpen;
  final VoidCallback onToggleCompare;
  final String? heroNamespace;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        const _PaddleLedGlow(),
        Padding(
          padding: const EdgeInsets.all(3),
          child: AppCard(
            selected: selected,
            onTap: onOpen,
            padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PaddleHeroImage(
                    paddle: paddle,
                    heroNamespace: heroNamespace,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.md,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.5),
                    child: ColoredBox(
                      color: colors.primary.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.35
                            : 0.22,
                      ),
                    ),
                  ),
                ),
                Text(
                  paddle.brand,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  paddle.name,
                  style: textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  paddle.priceUsd == null
                      ? 'Price unavailable'
                      : Formatters.priceUsd(paddle.priceUsd),
                  style: textTheme.titleSmall?.copyWith(color: colors.primary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  paddle.shape.label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: selected ? 'Remove from compare' : 'Add to compare',
                  icon: selected ? Icons.check_circle : Icons.add,
                  variant: selected
                      ? AppButtonVariant.tonal
                      : AppButtonVariant.secondary,
                  expanded: true,
                  onPressed: onToggleCompare,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaddleLedGlow extends StatelessWidget {
  const _PaddleLedGlow();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glow = Theme.of(context).colorScheme.primary;
    final halo = glow.withValues(alpha: isDark ? 0.75 : 0.55);

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 0.72,
            colors: [
              glow.withValues(alpha: isDark ? 0.92 : 0.82),
              halo,
              glow.withValues(alpha: 0),
            ],
            stops: const [0, 0.45, 1],
          ),
          boxShadow: [BoxShadow(color: halo, blurRadius: 10)],
        ),
      ),
    );
  }
}
