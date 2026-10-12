import '../entities/paddle.dart';
import '../repositories/paddle_repository.dart';

class GetPaddlesUseCase {
  const GetPaddlesUseCase(this._repository);

  final PaddleRepository _repository;

  Future<List<Paddle>> call() => _repository.getPaddles();
}
