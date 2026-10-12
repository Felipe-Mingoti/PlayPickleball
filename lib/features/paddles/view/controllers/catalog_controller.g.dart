// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CatalogController)
final catalogControllerProvider = CatalogControllerProvider._();

final class CatalogControllerProvider
    extends $NotifierProvider<CatalogController, PaddleFilterParams> {
  CatalogControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogControllerHash();

  @$internal
  @override
  CatalogController create() => CatalogController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaddleFilterParams value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaddleFilterParams>(value),
    );
  }
}

String _$catalogControllerHash() => r'65c1b130278ae4d0b16a502a2ca4738223c0f529';

abstract class _$CatalogController extends $Notifier<PaddleFilterParams> {
  PaddleFilterParams build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PaddleFilterParams, PaddleFilterParams>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaddleFilterParams, PaddleFilterParams>,
              PaddleFilterParams,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
