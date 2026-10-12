/// Generic failure raised when a data source cannot load its payload.
class DataLoadFailure implements Exception {
  const DataLoadFailure([this.message = 'Unable to load data.']);

  final String message;

  @override
  String toString() => message;
}
