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
import 'hero_namespace.dart';

class ComparisonTable extends StatefulWidget {
  const ComparisonTable({
    super.key,
    required this.result,
    required this.selection,
    required this.highlightDifferences,
  });

  final ComparisonResult result;
  final ComparisonSelection selection;
  final bool highlightDifferences;

  @override
  State<ComparisonTable> createState() => _ComparisonTableState();
}

class _ComparisonTableState extends State<ComparisonTable> {
  late final ScrollController _headerController;
  late final ScrollController _bodyController;
  var _syncing = false;
  var _showMoreHint = false;

  @override
  void initState() {
    super.initState();
    _headerController = ScrollController();
    _bodyController = ScrollController()..addListener(_onBodyScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_bodyController.hasClients) return;
      final max = _bodyController.position.maxScrollExtent;
      setState(() => _showMoreHint = max > 8);
    });
  }

  @override
  void dispose() {
    _bodyController.removeListener(_onBodyScroll);
    _headerController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _onBodyScroll() {
    if (!_bodyController.hasClients) return;
    final max = _bodyController.position.maxScrollExtent;
    final show = max > 8 && _bodyController.offset < max - 8;
    if (show != _showMoreHint) {
      setState(() => _showMoreHint = show);
    }
    _syncScroll(_bodyController, _headerController);
  }

  void _syncScroll(ScrollController source, ScrollController target) {
    if (_syncing || !target.hasClients) return;
    _syncing = true;
    target.jumpTo(source.offset.clamp(
      target.position.minScrollExtent,
      target.position.maxScrollExtent,
    ));
    _syncing = false;
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
    final columnWidth = compact ? 168.0 : 220.0;
    final lowest = _lowestPrice;
    final paddles = widget.result.paddles;

    final header = Row(
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
                extra: const PaddleHeroExtra(namespace: HeroNamespace.compare),
              );
            },
          ),
      ],
    );

    final rows = <Widget>[];
    String? currentCategory;
    var alt = false;
    for (final row in widget.result.rows) {
      if (row.category != currentCategory) {
        final category = row.category;
        currentCategory = category;
        rows.add(
          ComparisonRow(
            label: category,
            values: List.filled(paddles.length, ''),
            differs: false,
            highlightDifferences: false,
            labelWidth: labelWidth,
            columnWidth: columnWidth,
            isHeader: true,
          ),
        );
        alt = false;
      }
      rows.add(
        ComparisonRow(
          label: row.label,
          values: row.values,
          differs: row.differs,
          highlightDifferences: widget.highlightDifferences,
          labelWidth: labelWidth,
          columnWidth: columnWidth,
          alternating: alt,
        ),
      );
      alt = !alt;
    }

    Widget scrollable(Widget child, ScrollController controller) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.horizontal &&
              identical(controller, _headerController) &&
              notification is ScrollUpdateNotification) {
            _syncScroll(_headerController, _bodyController);
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
          child: child,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (compact && paddles.length > 1 && _showMoreHint)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Swipe sideways to see more paddles',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
            ),
          ),
        if (compact) ...[
          scrollable(header, _headerController),
          const SizedBox(height: AppSpacing.md),
          scrollable(Column(children: rows), _bodyController),
        ] else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: labelWidth + (columnWidth * paddles.length),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: AppSpacing.md),
                  ...rows,
                ],
              ),
            ),
          ),
      ],
    );
  }
}

extension on BuildContext {
  GoRouter get router => GoRouter.of(this);
}
