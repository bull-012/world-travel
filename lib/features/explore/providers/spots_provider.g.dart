// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spots_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$spotsHash() => r'22caa5197738854231a7edb9024d0295f5ff9acf';

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
String _$rankedSpotsHash() => r'a413fe8e537cb52474ebecf665ffef1102c3fe92';

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
String _$spotsFilterHash() => r'4479d7e6397ee53146c281cf252f9b8047137226';

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
