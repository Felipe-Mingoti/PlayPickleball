import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../common/extensions/context_extensions.dart';
import '../../../../common/widgets/buttons/app_button.dart';
import '../../../../common/widgets/buttons/app_icon_button.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/paddle.dart';
import 'paddle_hero_image.dart';

class ComparisonProductHeader extends StatelessWidget {
  const ComparisonProductHeader({
    super.key,
    required this.paddle,
    required this.onRemove,
    required this.onOpenDetails,
    this.isLowestPrice = false,
    this.heroNamespace,
    this.width,
  });

  final Paddle paddle;
  final VoidCallback onRemove;
  final VoidCallback onOpenDetails;
  final bool isLowestPrice;
  final String? heroNamespace;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: AppIconButton(
              icon: Icons.close,
              tooltip: 'Remove from compare',
              onPressed: onRemove,
            ),
          ),
          AspectRatio(
            aspectRatio: 3 / 4,
            child: PaddleHeroImage(
              paddle: paddle,
              heroNamespace: heroNamespace,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            paddle.brand,
            style: textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Text(
            paddle.name,
            style: textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Flexible(
                child: Text(
                  Formatters.priceUsd(paddle.priceUsd),
                  style: textTheme.titleSmall?.copyWith(color: colors.primary),
                ),
              ),
              if (isLowestPrice) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.semanticColors.priceBadge,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Lowest price',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Text(
            paddle.shape.label,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Details',
            variant: AppButtonVariant.text,
            onPressed: onOpenDetails,
          ),
        ],
      ),
    );
  }
}
