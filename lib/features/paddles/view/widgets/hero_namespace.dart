/// Hero tag namespaces avoid duplicate-tag conflicts when the same paddle
/// appears in catalog, similar carousel, and comparison UI at once.
///
/// Detail adopts the source namespace only when navigation `extra` provides it.
/// Direct links render without a Hero.
abstract final class HeroNamespace {
  static const catalog = 'catalog';
  static const similar = 'similar';
  static const compare = 'compare';

  static String tag(String namespace, String paddleId) => '$namespace:$paddleId';
}

class PaddleHeroExtra {
  const PaddleHeroExtra({required this.namespace});

  final String namespace;
}
