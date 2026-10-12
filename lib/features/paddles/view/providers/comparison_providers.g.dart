// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comparison_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(comparisonResult)
final comparisonResultProvider = ComparisonResultFamily._();

final class ComparisonResultProvider
    extends
        $FunctionalProvider<
          AsyncValue<ComparisonResult>,
          AsyncValue<ComparisonResult>,
          AsyncValue<ComparisonResult>
        >
    with $Provider<AsyncValue<ComparisonResult>> {
  ComparisonResultProvider._({
    required ComparisonResultFamily super.from,
    required ComparisonSelection super.argument,
  }) : super(
         retry: null,
         name: r'comparisonResultProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$comparisonResultHash();

  @override
  String toString() {
    return r'comparisonResultProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<ComparisonResult>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<ComparisonResult> create(Ref ref) {
    final argument = this.argument as ComparisonSelection;
    return comparisonResult(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ComparisonResult> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ComparisonResult>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ComparisonResultProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$comparisonResultHash() => r'7637cbb5462312be40c0d99b07b3421f95d8ec0e';

final class ComparisonResultFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<ComparisonResult>,
          ComparisonSelection
        > {
  ComparisonResultFamily._()
    : super(
        retry: null,
        name: r'comparisonResultProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ComparisonResultProvider call(ComparisonSelection selection) =>
      ComparisonResultProvider._(argument: selection, from: this);

  @override
  String toString() => r'comparisonResultProvider';
}

@ProviderFor(similarPaddles)
final similarPaddlesProvider = SimilarPaddlesFamily._();

final class SimilarPaddlesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Paddle>>,
          AsyncValue<List<Paddle>>,
          AsyncValue<List<Paddle>>
        >
    with $Provider<AsyncValue<List<Paddle>>> {
  SimilarPaddlesProvider._({
    required SimilarPaddlesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'similarPaddlesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$similarPaddlesHash();

  @override
  String toString() {
    return r'similarPaddlesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Paddle>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Paddle>> create(Ref ref) {
    final argument = this.argument as String;
    return similarPaddles(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Paddle>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Paddle>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SimilarPaddlesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$similarPaddlesHash() => r'ceb444734a2f474188fec6bdf1b73746de4c18e2';

final class SimilarPaddlesFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<Paddle>>, String> {
  SimilarPaddlesFamily._()
    : super(
        retry: null,
        name: r'similarPaddlesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SimilarPaddlesProvider call(String id) =>
      SimilarPaddlesProvider._(argument: id, from: this);

  @override
  String toString() => r'similarPaddlesProvider';
}
