abstract final class RoutePaths {
  static const String root = '/';
  static const String paddles = '/paddles';
  static const String paddleDetail = '/paddles/:id';
  static const String compare = '/compare';

  static const String idsQueryKey = 'ids';

  static String paddleDetailPath(String id) => '/paddles/$id';
}
