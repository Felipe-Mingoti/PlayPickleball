import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/paddle.dart';

class PaddleSpecs extends StatelessWidget {
  const PaddleSpecs({
    super.key,
    required this.paddle,
    this.compact = false,
  });

  final Paddle paddle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final groups = _groups(paddle);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          Text(group.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ...group.rows.map(
            (row) => _SpecRow(label: row.$1, value: row.$2),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }

  List<_SpecGroup> _groups(Paddle paddle) {
    return [
      _SpecGroup(
        title: 'General',
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
        rows: [
          ('Length', Formatters.inches(paddle.dimensions.lengthIn)),
          ('Width', Formatters.inches(paddle.dimensions.widthIn)),
          ('Handle length', Formatters.inches(paddle.dimensions.handleLengthIn)),
          ('Grip circumference', Formatters.inches(paddle.gripCircumferenceIn)),
        ],
      ),
      _SpecGroup(
        title: 'Construction',
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
        rows: [
          (
            'Swing weight',
            paddle.swingWeight?.toString() ?? 'Not available',
          ),
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
      (
        'Weight',
        paddle.weight?.displayOz ?? 'Not available',
      ),
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
  const _SpecGroup({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
