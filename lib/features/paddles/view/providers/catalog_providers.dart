import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/paddle.dart';
import '../controllers/catalog_controller.dart';
import 'paddle_providers.dart';

part 'catalog_providers.g.dart';

@riverpod
AsyncValue<List<Paddle>> filteredPaddles(Ref ref) {
  final params = ref.watch(catalogControllerProvider);
  final filter = ref.watch(filterPaddlesUseCaseProvider);
  return ref.watch(paddlesProvider).whenData(
        (paddles) => filter(paddles: paddles, params: params),
      );
}
