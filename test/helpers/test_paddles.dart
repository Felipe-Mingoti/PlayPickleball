import 'package:play_pickleball/core/errors/data_load_failure.dart';
import 'package:play_pickleball/features/paddles/domain/entities/paddle.dart';
import 'package:play_pickleball/features/paddles/domain/repositories/paddle_repository.dart';

import 'paddle_fixtures.dart';

class FakePaddleRepository implements PaddleRepository {
  FakePaddleRepository({
    List<Paddle>? paddles,
    this.failOnce = false,
  }) : paddles = paddles ?? samplePaddles;

  final List<Paddle> paddles;
  bool failOnce;
  var _failed = false;

  @override
  Future<List<Paddle>> getPaddles() async {
    if (failOnce && !_failed) {
      _failed = true;
      throw const DataLoadFailure('Network request failed. Please try again.');
    }
    return List<Paddle>.unmodifiable(paddles);
  }
}

final samplePaddles = [
  makePaddle(
    id: 'apex-court-summit-pro-16',
    brand: 'Apex Court',
    name: 'Summit Pro 16',
    priceUsd: 249.99,
    shape: PaddleShape.elongated,
    imagePath: 'assets/images/paddles/apex-court-summit-pro-16.png',
  ),
  makePaddle(
    id: 'dinkworks-soft-touch-16',
    brand: 'Dinkworks',
    name: 'Soft Touch 16',
    priceUsd: 159,
    shape: PaddleShape.standard,
    imagePath: 'assets/images/paddles/dinkworks-soft-touch-16.png',
  ),
  makePaddle(
    id: 'erne-athletics-airborne-14',
    brand: 'Erne Athletics',
    name: 'Airborne 14',
    priceUsd: 239,
    shape: PaddleShape.elongated,
    imagePath: 'assets/images/paddles/erne-athletics-airborne-14.png',
  ),
  makePaddle(
    id: 'kitchen-line-co-transition',
    brand: 'Kitchen Line Co.',
    name: 'Transition',
    priceUsd: 169,
    shape: PaddleShape.hybrid,
  ),
];
