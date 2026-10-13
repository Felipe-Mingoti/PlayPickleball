import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

/// Bordered section card with an icon, title, and rotating chevron.
///
/// Shared by paddle details and the comparison table so both stay in sync.
class ExpandableSection extends StatefulWidget {
  const ExpandableSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  late bool _expanded = widget.initiallyExpanded;

  static const _duration = Duration(milliseconds: 200);

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primary = colors.primary;
    final borderColor = primary.withValues(alpha: 0.45);

    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: _expanded,
            child: InkWell(
              onTap: _toggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSpacing.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(widget.icon, size: 18, color: primary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: primary),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: _duration,
                        curve: Curves.easeInOut,
                        child: Icon(Icons.expand_more, color: primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: _duration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? widget.child
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
