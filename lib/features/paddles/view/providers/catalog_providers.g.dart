// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(filteredPaddles)
final filteredPaddlesProvider = FilteredPaddlesProvider._();

final class FilteredPaddlesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Paddle>>,
          AsyncValue<List<Paddle>>,
          AsyncValue<List<Paddle>>
        >
    with $Provider<AsyncValue<List<Paddle>>> {
  FilteredPaddlesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredPaddlesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredPaddlesHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Paddle>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Paddle>> create(Ref ref) {
    return filteredPaddles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Paddle>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Paddle>>>(value),
    );
  }
}

String _$filteredPaddlesHash() => r'8a50f84a69e4373e36595c7cded55af06ebea3eb';
