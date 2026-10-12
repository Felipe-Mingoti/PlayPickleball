import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/router/comparison_route_codec.dart';
import '../../domain/entities/paddle.dart';
import '../../domain/usecases/compare_paddles_usecase.dart';
import '../../domain/value_objects/comparison_selection.dart';
import 'paddle_providers.dart';

part 'comparison_providers.g.dart';

/// Reads the canonical comparison selection from the current route URI.
ComparisonSelection selectionFromContext(BuildContext context) {
  return ComparisonRouteCodec.parse(GoRouterState.of(context).uri);
}

@riverpod
AsyncValue<ComparisonResult> comparisonResult(
  Ref ref,
  ComparisonSelection selection,
) {
  final compare = ref.watch(comparePaddlesUseCaseProvider);
  return ref.watch(paddlesProvider).whenData(
        (paddles) => compare(selection: selection, paddles: paddles),
      );
}

@riverpod
AsyncValue<List<Paddle>> similarPaddles(Ref ref, String id) {
  final findSimilar = ref.watch(findSimilarPaddlesUseCaseProvider);
  return ref.watch(paddlesProvider).whenData((paddles) {
    Paddle? selected;
    for (final paddle in paddles) {
      if (paddle.id == id) {
        selected = paddle;
        break;
      }
    }
    if (selected == null) return const <Paddle>[];
    return findSimilar(selected: selected, paddles: paddles);
  });
}

/// Navigation helpers that keep URL as the source of truth for selection.
extension ComparisonNavigation on GoRouter {
  ComparisonSelection readSelection() {
    return ComparisonRouteCodec.parse(routeInformationProvider.value.uri);
  }

  void replaceSelection(ComparisonSelection selection) {
    final current = routeInformationProvider.value.uri;
    final next = ComparisonRouteCodec.withSelection(current, selection);
    replace(next.toString());
  }

  void goCatalog({ComparisonSelection? selection}) {
    final ids = selection ?? readSelection();
    final uri = ComparisonRouteCodec.withSelection(
      Uri(path: '/paddles'),
      ids,
    );
    go(uri.toString());
  }

  void goCompare({ComparisonSelection? selection}) {
    final ids = selection ?? readSelection();
    final uri = ComparisonRouteCodec.withSelection(
      Uri(path: '/compare'),
      ids,
    );
    go(uri.toString());
  }

  void goPaddleDetail(
    String id, {
    ComparisonSelection? selection,
    Object? extra,
  }) {
    final ids = selection ?? readSelection();
    final uri = ComparisonRouteCodec.withSelection(
      Uri(path: '/paddles/$id'),
      ids,
    );
    go(uri.toString(), extra: extra);
  }
}
