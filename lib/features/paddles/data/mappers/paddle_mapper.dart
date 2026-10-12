import '../../../../core/constants/asset_paths.dart';
import '../../domain/entities/paddle.dart';
import '../../domain/value_objects/paddle_weight.dart';
import '../models/paddle_model.dart';

class PaddleMapper {
  const PaddleMapper();

  Paddle? toEntity(PaddleModel model) {
    final dimensions = model.dimensions;
    final length = dimensions?.length?.toDouble();
    final width = dimensions?.width?.toDouble();
    final handle = dimensions?.handleLength?.toDouble();
    if (length == null || width == null || handle == null) {
      return null;
    }

    final ratings = model.ratings;
    if (ratings?.power == null ||
        ratings?.control == null ||
        ratings?.pop == null) {
      return null;
    }

    final grip = model.gripCircumferenceIn;
    final core = model.coreThicknessMm;
    final year = model.releaseYear;
    if (grip == null || core == null || year == null) {
      return null;
    }

    return Paddle(
      id: model.id,
      brand: model.brand,
      name: model.name,
      releaseYear: year,
      priceUsd: model.priceUsd,
      inStock: model.inStock ?? false,
      shape: PaddleShape.fromRaw(model.shape),
      faceMaterial: (model.faceMaterial?.trim().isEmpty ?? true)
          ? 'Not available'
          : model.faceMaterial!.trim(),
      coreThicknessMm: core,
      weight: PaddleWeight.tryParse(
        value: model.weight?.value,
        unit: model.weight?.unit,
      ),
      swingWeight: model.swingWeight,
      twistWeight: model.twistWeight,
      dimensions: PaddleDimensions(
        lengthIn: length,
        widthIn: width,
        handleLengthIn: handle,
      ),
      gripCircumferenceIn: grip,
      ratings: PaddleRatings(
        power: ratings!.power!,
        control: ratings.control!,
        pop: ratings.pop!,
        spin: ratings.spin,
      ),
      imagePath: _normalizeImagePath(model.imagePath),
      description: model.description?.trim() ?? '',
    );
  }

  List<Paddle> toEntityList(Iterable<PaddleModel> models) {
    final paddles = <Paddle>[];
    for (final model in models) {
      final entity = toEntity(model);
      if (entity != null) paddles.add(entity);
    }
    return paddles;
  }

  String? _normalizeImagePath(String? path) {
    if (path == null) return null;
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;
    if (!trimmed.startsWith(AssetPaths.paddleImagesPrefix)) return null;
    if (!(trimmed.endsWith('.png') || trimmed.endsWith('.jpg') || trimmed.endsWith('.jpeg'))) {
      return null;
    }
    return trimmed;
  }
}
