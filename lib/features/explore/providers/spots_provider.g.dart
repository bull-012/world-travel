// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spots_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$spotsHash() => r'472916f47ae25fded61acdff917ff493fecd00e4';

/// See also [spots].
@ProviderFor(spots)
final spotsProvider = AutoDisposeFutureProvider<List<Spot>>.internal(
  spots,
  name: r'spotsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$spotsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SpotsRef = AutoDisposeFutureProviderRef<List<Spot>>;
String _$rankedSpotsHash() => r'841f820a0b4812b0b5bea352b7351d59c5db0f94';

/// See also [rankedSpots].
@ProviderFor(rankedSpots)
final rankedSpotsProvider = AutoDisposeFutureProvider<List<Spot>>.internal(
  rankedSpots,
  name: r'rankedSpotsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$rankedSpotsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RankedSpotsRef = AutoDisposeFutureProviderRef<List<Spot>>;
String _$spotsFilterHash() => r'dfbb37bbd3e7fc9fffebff9b79441507bddb7c86';

/// See also [SpotsFilter].
@ProviderFor(SpotsFilter)
final spotsFilterProvider =
    AutoDisposeNotifierProvider<SpotsFilter, SpotFilter>.internal(
  SpotsFilter.new,
  name: r'spotsFilterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$spotsFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpotsFilter = AutoDisposeNotifier<SpotFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
