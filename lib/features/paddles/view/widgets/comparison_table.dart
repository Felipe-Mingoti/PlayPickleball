import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../common/extensions/context_extensions.dart';
import '../../../../common/layouts/responsive_layout.dart';
import '../../domain/usecases/compare_paddles_usecase.dart';
import '../../domain/value_objects/comparison_selection.dart';
import '../providers/comparison_providers.dart';
import 'comparison_product_header.dart';
import 'comparison_row.dart';
import 'expandable_section.dart';
import 'hero_namespace.dart';

class ComparisonTable extends StatefulWidget {
  const ComparisonTable({
    super.key,
    required this.result,
    required this.selection,
    required this.highlightDifferences,
    required this.pinnedAttributes,
    required this.onTogglePin,
  });

  final ComparisonResult result;
  final ComparisonSelection selection;
  final bool highlightDifferences;
  final List<ComparisonAttribute> pinnedAttributes;
  final ValueChanged<ComparisonAttribute> onTogglePin;

  @override
  State<ComparisonTable> createState() => _ComparisonTableState();
}

class _ComparisonTableState extends State<ComparisonTable> {
  final _sync = _ScrollSync();

  static const _compactColumnWidth = 168.0;
  static const _wideColumnWidth = 220.0;
  static const _maxColumnWidth = 420.0;

  static const _groups = <(String, IconData)>[
    ('General', Icons.info_outline),
    ('Dimensions', Icons.straighten),
    ('Construction', Icons.layers_outlined),
    ('Performance', Icons.speed),
  ];

  @override
  void dispose() {
    _sync.dispose();
    super.dispose();
  }

  double _columnWidth({
    required double viewportWidth,
    required double labelWidth,
    required double minColumnWidth,
    required int paddleCount,
  }) {
    if (paddleCount == 0) return minColumnWidth;
    final grown = (viewportWidth - labelWidth) / paddleCount;
    return math.min(_maxColumnWidth, math.max(minColumnWidth, grown));
  }

  double? get _lowestPrice {
    final prices = widget.result.paddles
        .map((p) => p.priceUsd)
        .whereType<double>()
        .toList();
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final compact =
        ResponsiveLayout.breakpointOf(context) == AppBreakpoint.compact;
    final labelWidth = AppSpacing.compareLabelColumnWidth;
    final minColumnWidth = compact ? _compactColumnWidth : _wideColumnWidth;
    final paddles = widget.result.paddles;
    final lowest = _lowestPrice;
    final rowsByAttribute = {
      for (final row in widget.result.rows) row.attribute: row,
    };
    final pinned = <ComparisonSpecRow>[
      for (final attribute in widget.pinnedAttributes)
        if (rowsByAttribute[attribute] != null) rowsByAttribute[attribute]!,
    ];
    final pinnedIds = widget.pinnedAttributes.toSet();
    final remaining = <String, List<ComparisonSpecRow>>{};
    for (final row in widget.result.rows) {
      if (pinnedIds.contains(row.attribute)) continue;
      remaining.putIfAbsent(row.category, () => []).add(row);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : labelWidth + (minColumnWidth * paddles.length);
        final columnWidth = _columnWidth(
          viewportWidth: viewportWidth,
          labelWidth: labelWidth,
          minColumnWidth: minColumnWidth,
          paddleCount: paddles.length,
        );
        final contentWidth = labelWidth + (columnWidth * paddles.length);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SwipeHint(
              sync: _sync,
              compact: compact,
              maxExtent: math.max(0, contentWidth - viewportWidth),
            ),
            _LinkedHScroll(
              key: const ValueKey('compare-cards'),
              sync: _sync,
              width: contentWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: labelWidth),
                  for (final paddle in paddles)
                    ComparisonProductHeader(
                      paddle: paddle,
                      width: columnWidth,
                      isLowestPrice:
                          paddle.priceUsd != null && paddle.priceUsd == lowest,
                      heroNamespace: HeroNamespace.compare,
                      onRemove: () {
                        context.router.replaceSelection(
                          widget.selection.remove(paddle.id),
                        );
                      },
                      onOpenDetails: () {
                        context.router.goPaddleDetail(
                          paddle.id,
                          selection: widget.selection,
                          extra: const PaddleHeroExtra(
                            namespace: HeroNamespace.compare,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _section(
              title: 'Your picks',
              icon: Icons.push_pin_outlined,
              rows: pinned,
              empty: const _EmptyPicksHint(),
              labelWidth: labelWidth,
              columnWidth: columnWidth,
              contentWidth: contentWidth,
              pinned: true,
            ),
            for (final group in _groups)
              if (remaining[group.$1]?.isNotEmpty ?? false) ...[
                const SizedBox(height: AppSpacing.md),
                _section(
                  title: group.$1,
                  icon: group.$2,
                  rows: remaining[group.$1]!,
                  labelWidth: labelWidth,
                  columnWidth: columnWidth,
                  contentWidth: contentWidth,
                  pinned: false,
                ),
              ],
          ],
        );
      },
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<ComparisonSpecRow> rows,
    required double labelWidth,
    required double columnWidth,
    required double contentWidth,
    required bool pinned,
    Widget? empty,
  }) {
    final body = rows.isEmpty && empty != null
        ? empty
        : Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _LinkedHScroll(
              key: ValueKey('compare-rows-$title'),
              sync: _sync,
              width: contentWidth,
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++)
                    ComparisonRow(
                      label: rows[i].label,
                      values: rows[i].values,
                      differs: rows[i].differs,
                      highlightDifferences: widget.highlightDifferences,
                      labelWidth: labelWidth,
                      columnWidth: columnWidth,
                      pinned: pinned,
                      onPinToggle: () => widget.onTogglePin(rows[i].attribute),
                    ),
                ],
              ),
            ),
          );

    return ExpandableSection(
      key: ValueKey('compare-section-$title'),
      title: title,
      icon: icon,
      initiallyExpanded: true,
      child: body,
    );
  }
}

class _EmptyPicksHint extends StatelessWidget {
  const _EmptyPicksHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Text(
        'Tap a row to pin it here, up to 5.',
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: context.colors.onSurfaceVariant),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({
    required this.sync,
    required this.compact,
    required this.maxExtent,
  });

  final _ScrollSync sync;
  final bool compact;
  final double maxExtent;

  @override
  Widget build(BuildContext context) {
    if (!compact) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: sync,
      builder: (context, _) {
        final show = maxExtent > 8 && sync.offset < maxExtent - 8;
        if (!show) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            'Swipe sideways to see more paddles',
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
        );
      },
    );
  }
}

class _LinkedHScroll extends StatefulWidget {
  const _LinkedHScroll({
    super.key,
    required this.sync,
    required this.width,
    required this.child,
  });

  final _ScrollSync sync;
  final double width;
  final Widget child;

  @override
  State<_LinkedHScroll> createState() => _LinkedHScrollState();
}

class _LinkedHScrollState extends State<_LinkedHScroll> {
  late final ScrollController _controller;

  static const _physics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    widget.sync.attach(_controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.sync.align(_controller);
    });
  }

  @override
  void didUpdateWidget(covariant _LinkedHScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.sync, widget.sync)) {
      oldWidget.sync.detach(_controller);
      widget.sync.attach(_controller);
    }
  }

  @override
  void dispose() {
    widget.sync.detach(_controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scroll = SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      primary: false,
      physics: _physics,
      child: SizedBox(width: widget.width, child: widget.child),
    );
    if (!kIsWeb) return scroll;

    final behavior = ScrollConfiguration.of(context);
    return ScrollConfiguration(
      behavior: behavior.copyWith(
        dragDevices: {...behavior.dragDevices, PointerDeviceKind.mouse},
      ),
      child: scroll,
    );
  }
}

/// Keeps every horizontal strip on the same offset.
class _ScrollSync extends ChangeNotifier {
  final List<ScrollController> _controllers = [];
  final Map<ScrollController, VoidCallback> _listeners = {};
  var _syncing = false;
  double _offset = 0;

  double get offset => _offset;

  void attach(ScrollController controller) {
    if (_listeners.containsKey(controller)) return;
    void listener() => _from(controller);
    _listeners[controller] = listener;
    _controllers.add(controller);
    controller.addListener(listener);
  }

  void detach(ScrollController controller) {
    final listener = _listeners.remove(controller);
    if (listener != null) controller.removeListener(listener);
    _controllers.remove(controller);
  }

  void align(ScrollController controller) {
    if (!controller.hasClients || _syncing) return;
    final position = controller.position;
    final target = _offset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((controller.offset - target).abs() < 0.5) return;
    _syncing = true;
    controller.jumpTo(target);
    _syncing = false;
  }

  void _from(ScrollController source) {
    if (_syncing || !source.hasClients) return;
    _offset = source.offset;
    _syncing = true;
    for (final other in List<ScrollController>.of(_controllers)) {
      if (identical(other, source) || !other.hasClients) continue;
      final position = other.position;
      final target = _offset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if ((other.offset - target).abs() < 0.5) continue;
      other.jumpTo(target);
    }
    _syncing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final entry in _listeners.entries.toList()) {
      entry.key.removeListener(entry.value);
    }
    _listeners.clear();
    _controllers.clear();
    super.dispose();
  }
}

extension on BuildContext {
  GoRouter get router => GoRouter.of(this);
}
