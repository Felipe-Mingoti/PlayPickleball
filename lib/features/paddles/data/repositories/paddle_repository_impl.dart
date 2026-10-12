import '../../domain/entities/paddle.dart';
import '../../domain/repositories/paddle_repository.dart';
import '../datasources/paddle_mock_datasource.dart';
import '../mappers/paddle_mapper.dart';

class PaddleRepositoryImpl implements PaddleRepository {
  PaddleRepositoryImpl({
    required this.dataSource,
    this.mapper = const PaddleMapper(),
  });

  final PaddleMockDataSource dataSource;
  final PaddleMapper mapper;

  @override
  Future<List<Paddle>> getPaddles() async {
    final models = await dataSource.fetchPaddles();
    return mapper.toEntityList(models);
  }
}
