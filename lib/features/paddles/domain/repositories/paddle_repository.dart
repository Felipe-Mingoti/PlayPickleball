import '../entities/paddle.dart';

abstract class PaddleRepository {
  Future<List<Paddle>> getPaddles();
}
