import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../common/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/paddle.dart';
import 'expandable_section.dart';

class PaddleSpecs extends StatelessWidget {
  const PaddleSpecs({super.key, required this.paddle, this.compact = false});

  final Paddle paddle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final groups = _groups(paddle);
    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _section(groups[i], wide: false),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < groups.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _section(groups[i], wide: true)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: i + 1 < groups.length
                    ? _section(groups[i + 1], wide: true)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _section(_SpecGroup group, {required bool wide}) {
    return ExpandableSection(
      key: ValueKey(group.title),
      title: group.title,
      icon: group.icon,
      initiallyExpanded:
          group.initiallyExpanded || (wide && group.initiallyExpandedOnWide),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xs,
        ),
        child: Column(
          children: [
            for (var i = 0; i < group.rows.length; i++)
              _SpecRow(
                label: group.rows[i].$1,
                value: group.rows[i].$2,
                showDivider: i < group.rows.length - 1,
              ),
          ],
        ),
      ),
    );
  }

  List<_SpecGroup> _groups(Paddle paddle) {
    return [
      _SpecGroup(
        title: 'General',
        icon: Icons.info_outline,
        initiallyExpanded: true,
        rows: [
          ('Brand', paddle.brand),
          ('Model', paddle.name),
          ('Price', Formatters.priceUsd(paddle.priceUsd)),
          ('Shape', paddle.shape.label),
          ('Release year', paddle.releaseYear.toString()),
          ('Availability', paddle.inStock ? 'In stock' : 'Out of stock'),
          (
            'Description',
            paddle.description.trim().isEmpty
                ? 'Not available'
                : paddle.description,
          ),
        ],
      ),
      _SpecGroup(
        title: 'Dimensions',
        icon: Icons.straighten,
        initiallyExpandedOnWide: true,
        rows: [
          ('Length', Formatters.inches(paddle.dimensions.lengthIn)),
          ('Width', Formatters.inches(paddle.dimensions.widthIn)),
          (
            'Handle length',
            Formatters.inches(paddle.dimensions.handleLengthIn),
          ),
          ('Grip circumference', Formatters.inches(paddle.gripCircumferenceIn)),
        ],
      ),
      _SpecGroup(
        title: 'Construction',
        icon: Icons.layers_outlined,
        rows: [
          (
            'Weight',
            paddle.weight == null
                ? 'Not available'
                : [
                    paddle.weight!.displayOz,
                    if (paddle.weight!.originalLabel != null)
                      '(${paddle.weight!.originalLabel})',
                  ].join(' '),
          ),
          ('Core thickness', Formatters.millimeters(paddle.coreThicknessMm)),
          ('Face material', paddle.faceMaterial),
        ],
      ),
      _SpecGroup(
        title: 'Performance',
        icon: Icons.speed,
        rows: [
          ('Swing weight', paddle.swingWeight?.toString() ?? 'Not available'),
          (
            'Twist weight',
            paddle.twistWeight?.toStringAsFixed(1) ?? 'Not available',
          ),
          ('Power', paddle.ratings.power.toString()),
          ('Control', paddle.ratings.control.toString()),
          ('Spin', paddle.ratings.spin?.toString() ?? 'Not available'),
          ('Pop', paddle.ratings.pop.toString()),
        ],
      ),
    ];
  }
}

class PaddleKeySpecs extends StatelessWidget {
  const PaddleKeySpecs({super.key, required this.paddle});

  final Paddle paddle;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Shape', paddle.shape.label),
      ('Weight', paddle.weight?.displayOz ?? 'Not available'),
      ('Core', Formatters.millimeters(paddle.coreThicknessMm)),
      ('Control', paddle.ratings.control.toString()),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: items
          .map(
            (item) => Chip(
              label: Text('${item.$1}: ${item.$2}'),
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(),
    );
  }
}

class _SpecGroup {
  const _SpecGroup({
    required this.title,
    required this.icon,
    required this.rows,
    this.initiallyExpanded = false,
    this.initiallyExpandedOnWide = false,
  });

  final String title;
  final IconData icon;
  final bool initiallyExpanded;
  final bool initiallyExpandedOnWide;
  final List<(String, String)> rows;
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: colors.primary.withValues(alpha: 0.12),
                ),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                  letterSpacing: 0.15,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
