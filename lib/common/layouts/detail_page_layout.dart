import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../extensions/context_extensions.dart';
import '../widgets/branding/app_footer.dart';

/// Reusable product-detail composition. Feature screens fill the slots.
class DetailPageLayout extends StatelessWidget {
  const DetailPageLayout({
    super.key,
    required this.image,
    required this.summary,
    this.actions,
    this.details,
    this.additionalContent,
  });

  final Widget image;
  final Widget summary;
  final Widget? actions;
  final Widget? details;
  final Widget? additionalContent;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final maxImageHeight =
        MediaQuery.sizeOf(context).height * (compact ? 0.38 : 0.55);

    final imageBlock = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxImageHeight),
      child: image,
    );

    final summaryColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        summary,
        if (actions != null) ...[
          const SizedBox(height: AppSpacing.lg),
          actions!,
        ],
      ],
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: context.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (compact) ...[
                  imageBlock,
                  const SizedBox(height: AppSpacing.xl),
                  summaryColumn,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: imageBlock),
                      const SizedBox(width: AppSpacing.xxl),
                      Expanded(flex: 6, child: summaryColumn),
                    ],
                  ),
                if (details != null) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  details!,
                ],
                if (additionalContent != null) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  additionalContent!,
                ],
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}
