import 'package:flutter/material.dart';

import '../../../../common/widgets/images/app_image_placeholder.dart';
import '../../domain/entities/paddle.dart';
import 'hero_namespace.dart';

class PaddleHeroImage extends StatelessWidget {
  const PaddleHeroImage({
    super.key,
    required this.paddle,
    this.heroNamespace,
    this.height,
    this.backgroundColor,
  });

  final Paddle paddle;
  final String? heroNamespace;
  final double? height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final colors = Theme.of(context).colorScheme;

    Widget image;
    final path = paddle.imagePath;
    if (path == null) {
      image = const AppImagePlaceholder();
    } else {
      image = Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const AppImagePlaceholder(),
      );
    }

    final framed = ColoredBox(
      color: backgroundColor ??
          colors.surfaceContainerHighest.withValues(alpha: 0.25),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: height == null
              ? image
              : SizedBox(height: height, child: image),
        ),
      ),
    );

    if (heroNamespace == null || reduceMotion) {
      return framed;
    }

    return Hero(
      tag: HeroNamespace.tag(heroNamespace!, paddle.id),
      child: Material(
        type: MaterialType.transparency,
        child: framed,
      ),
    );
  }
}
