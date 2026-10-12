import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/paddle_mock_datasource.dart';
import '../../data/repositories/paddle_repository_impl.dart';
import '../../domain/entities/paddle.dart';
import '../../domain/repositories/paddle_repository.dart';
import '../../domain/usecases/compare_paddles_usecase.dart';
import '../../domain/usecases/filter_paddles_usecase.dart';
import '../../domain/usecases/find_similar_paddles_usecase.dart';
import '../../domain/usecases/get_paddles_usecase.dart';

part 'paddle_providers.g.dart';

@Riverpod(keepAlive: true)
PaddleMockDataSource paddleMockDataSource(Ref ref) {
  return PaddleMockDataSource();
}

@Riverpod(keepAlive: true)
PaddleRepository paddleRepository(Ref ref) {
  return PaddleRepositoryImpl(
    dataSource: ref.watch(paddleMockDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
GetPaddlesUseCase getPaddlesUseCase(Ref ref) {
  return GetPaddlesUseCase(ref.watch(paddleRepositoryProvider));
}

@Riverpod(keepAlive: true)
FilterPaddlesUseCase filterPaddlesUseCase(Ref ref) {
  return const FilterPaddlesUseCase();
}

@Riverpod(keepAlive: true)
ComparePaddlesUseCase comparePaddlesUseCase(Ref ref) {
  return const ComparePaddlesUseCase();
}

@Riverpod(keepAlive: true)
FindSimilarPaddlesUseCase findSimilarPaddlesUseCase(Ref ref) {
  return const FindSimilarPaddlesUseCase();
}

Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(keepAlive: true, retry: _noRetry)
Future<List<Paddle>> paddles(Ref ref) {
  return ref.watch(getPaddlesUseCaseProvider).call();
}

@riverpod
Paddle? paddleById(Ref ref, String id) {
  final asyncPaddles = ref.watch(paddlesProvider);
  return asyncPaddles.maybeWhen(
    data: (paddles) {
      for (final paddle in paddles) {
        if (paddle.id == id) return paddle;
      }
      return null;
    },
    orElse: () => null,
  );
}
