import 'package:flutter/material.dart';

abstract final class ResponsiveBreakpoints {
  static const double medium = 600;
  static const double expanded = 900;
}

enum AppBreakpoint { compact, medium, expanded }

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final Widget compact;
  final Widget? medium;
  final Widget? expanded;

  static AppBreakpoint breakpointOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= ResponsiveBreakpoints.expanded) {
      return AppBreakpoint.expanded;
    }
    if (width >= ResponsiveBreakpoints.medium) {
      return AppBreakpoint.medium;
    }
    return AppBreakpoint.compact;
  }

  static int catalogColumns(BuildContext context) {
    return switch (breakpointOf(context)) {
      AppBreakpoint.compact => 1,
      AppBreakpoint.medium => 2,
      AppBreakpoint.expanded => 3,
    };
  }

  @override
  Widget build(BuildContext context) {
    return switch (breakpointOf(context)) {
      AppBreakpoint.expanded => expanded ?? medium ?? compact,
      AppBreakpoint.medium => medium ?? compact,
      AppBreakpoint.compact => compact,
    };
  }
}
