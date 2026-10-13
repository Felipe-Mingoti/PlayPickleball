import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../common/extensions/context_extensions.dart';
import '../../../../common/widgets/buttons/app_icon_button.dart';
import '../../domain/entities/paddle.dart';
import '../../domain/value_objects/comparison_selection.dart';
import '../providers/comparison_providers.dart';
import 'hero_namespace.dart';
import 'paddle_card.dart';

class SimilarPaddlesCarousel extends ConsumerStatefulWidget {
  const SimilarPaddlesCarousel({
    super.key,
    required this.paddleId,
    required this.selection,
    required this.onToggleCompare,
    required this.onLimitReached,
  });

  final String paddleId;
  final ComparisonSelection selection;
  final void Function(String paddleId) onToggleCompare;
  final VoidCallback onLimitReached;

  @override
  ConsumerState<SimilarPaddlesCarousel> createState() =>
      _SimilarPaddlesCarouselState();
}

class _SimilarPaddlesCarouselState
    extends ConsumerState<SimilarPaddlesCarousel> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final similarAsync = ref.watch(similarPaddlesProvider(widget.paddleId));

    return similarAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (paddles) {
        if (paddles.isEmpty) return const SizedBox.shrink();

        final cardWidth = context.isCompact
            ? MediaQuery.sizeOf(context).width * 0.72
            : 260.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You might also like',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Explore paddles with similar specifications.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (!context.isCompact) ...[
                  AppIconButton(
                    icon: Icons.chevron_left,
                    tooltip: 'Previous',
                    onPressed: () => _controller.animateTo(
                      (_controller.offset - cardWidth - AppSpacing.md)
                          .clamp(0, _controller.position.maxScrollExtent),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.chevron_right,
                    tooltip: 'Next',
                    onPressed: () => _controller.animateTo(
                      (_controller.offset + cardWidth + AppSpacing.md)
                          .clamp(0, _controller.position.maxScrollExtent),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: (context.isCompact ? 430 : 460) + AppSpacing.lg * 2,
              child: _carouselList(context, paddles, cardWidth),
            ),
          ],
        );
      },
    );
  }

  Widget _carouselList(
    BuildContext context,
    List<Paddle> paddles,
    double cardWidth,
  ) {
    final list = ListView.separated(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      itemCount: paddles.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
      itemBuilder: (context, index) {
        final paddle = paddles[index];
        final selected = widget.selection.contains(paddle.id);
        return SizedBox(
          width: cardWidth,
          child: PaddleCard(
            paddle: paddle,
            selected: selected,
            heroNamespace: HeroNamespace.similar,
            compact: true,
            onOpen: () {
              context.router.goPaddleDetail(
                paddle.id,
                selection: widget.selection,
                extra: const PaddleHeroExtra(
                  namespace: HeroNamespace.similar,
                ),
              );
            },
            onToggleCompare: () {
              if (!selected && widget.selection.isFull) {
                widget.onLimitReached();
                return;
              }
              widget.onToggleCompare(paddle.id);
            },
          ),
        );
      },
    );

    if (!kIsWeb || !context.isCompact) return list;

    final behavior = ScrollConfiguration.of(context);
    return ScrollConfiguration(
      behavior: behavior.copyWith(
        dragDevices: {
          ...behavior.dragDevices,
          PointerDeviceKind.mouse,
        },
      ),
      child: list,
    );
  }
}

extension on BuildContext {
  GoRouter get router => GoRouter.of(this);
}
