import '../entities/paddle.dart';

class FindSimilarPaddlesUseCase {
  const FindSimilarPaddlesUseCase({this.limit = 6});

  final int limit;

  List<Paddle> call({
    required Paddle selected,
    required List<Paddle> paddles,
  }) {
    final scored = <({Paddle paddle, double score})>[];

    for (final candidate in paddles) {
      if (candidate.id == selected.id) continue;
      scored.add((paddle: candidate, score: _score(selected, candidate)));
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.paddle.id.compareTo(b.paddle.id);
    });

    return scored.take(limit).map((entry) => entry.paddle).toList();
  }

  double _score(Paddle selected, Paddle candidate) {
    var score = 0.0;

    if (selected.shape == candidate.shape) {
      score += 4;
    }

    final selectedPrice = selected.priceUsd;
    final candidatePrice = candidate.priceUsd;
    if (selectedPrice != null && candidatePrice != null) {
      final delta = (selectedPrice - candidatePrice).abs();
      if (delta <= 80) {
        score += 2 * (1 - (delta / 80));
      }
    }

    final selectedWeight = selected.weight?.ounces;
    final candidateWeight = candidate.weight?.ounces;
    if (selectedWeight != null && candidateWeight != null) {
      final delta = (selectedWeight - candidateWeight).abs();
      if (delta <= 1) {
        score += 2 * (1 - delta);
      }
    }

    if (selected.coreThicknessMm == candidate.coreThicknessMm) {
      score += 1;
    }

    score += _ratingProximity(selected.ratings.power, candidate.ratings.power);
    score +=
        _ratingProximity(selected.ratings.control, candidate.ratings.control);
    score += _ratingProximity(selected.ratings.pop, candidate.ratings.pop);
    if (selected.ratings.spin != null && candidate.ratings.spin != null) {
      score += _ratingProximity(selected.ratings.spin!, candidate.ratings.spin!);
    }

    return score;
  }

  double _ratingProximity(int a, int b) {
    final delta = (a - b).abs();
    if (delta == 0) return 1;
    if (delta == 1) return 0.5;
    return 0;
  }
}
