import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_pickleball/core/errors/data_load_failure.dart';
import 'package:play_pickleball/features/paddles/data/datasources/paddle_mock_datasource.dart';
import 'package:play_pickleball/features/paddles/data/mappers/paddle_mapper.dart';
import 'package:play_pickleball/features/paddles/data/repositories/paddle_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads paddles from the asset and maps entities', () async {
    final dataSource = PaddleMockDataSource(
      latency: Duration.zero,
      failureRate: 0,
      shouldFail: () => false,
    );
    final repository = PaddleRepositoryImpl(
      dataSource: dataSource,
      mapper: const PaddleMapper(),
    );

    final paddles = await repository.getPaddles();
    expect(paddles, isNotEmpty);
    expect(paddles.any((p) => p.weight?.originalUnit == 'g'), isTrue);
  });

  test('simulates failure and recovers on retry', () async {
    var shouldFail = true;
    final dataSource = PaddleMockDataSource(
      latency: Duration.zero,
      shouldFail: () => shouldFail,
    );
    final repository = PaddleRepositoryImpl(dataSource: dataSource);

    await expectLater(
      repository.getPaddles(),
      throwsA(isA<DataLoadFailure>()),
    );

    shouldFail = false;
    final paddles = await repository.getPaddles();
    expect(paddles.length, greaterThan(10));
  });

  test('rejects malformed top-level payload', () async {
    final bundle = _FakeBundle('{"oops": true}');
    final dataSource = PaddleMockDataSource(
      bundle: bundle,
      latency: Duration.zero,
      shouldFail: () => false,
    );
    await expectLater(
      dataSource.fetchPaddles(),
      throwsA(isA<DataLoadFailure>()),
    );
  });
}

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.payload);

  final String payload;

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => payload;
}
