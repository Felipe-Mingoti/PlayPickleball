import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../../../../core/constants/asset_paths.dart';
import '../../../../core/errors/data_load_failure.dart';
import '../models/paddle_model.dart';

/// Simulates a remote API backed by a local JSON asset.
class PaddleMockDataSource {
  PaddleMockDataSource({
    AssetBundle? bundle,
    Duration? latency,
    this.failureRate = 0.12,
    Random? random,
    this.shouldFail,
  })  : _bundle = bundle ?? rootBundle,
        _latency = latency ?? const Duration(milliseconds: 500),
        _random = random ?? Random();

  final AssetBundle _bundle;
  final Duration _latency;
  final double failureRate;
  final Random _random;
  final bool Function()? shouldFail;

  Future<List<PaddleModel>> fetchPaddles() async {
    if (_latency > Duration.zero) {
      await Future<void>.delayed(_latency);
    }

    final fail = shouldFail?.call() ?? _random.nextDouble() < failureRate;
    if (fail) {
      throw const DataLoadFailure(
        'Network request failed. Please try again.',
      );
    }

    try {
      final raw = await _bundle.loadString(AssetPaths.paddlesJson);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const DataLoadFailure('Unexpected paddle payload.');
      }
      final list = decoded['paddles'];
      if (list is! List) {
        throw const DataLoadFailure('Unexpected paddle payload.');
      }

      final models = <PaddleModel>[];
      for (final item in list) {
        final model = PaddleModel.tryParse(item);
        if (model != null) models.add(model);
      }
      return models;
    } on DataLoadFailure {
      rethrow;
    } catch (_) {
      throw const DataLoadFailure('Unable to decode paddle data.');
    }
  }
}
