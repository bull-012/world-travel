// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$positionStreamHash() => r'f3c847610d45e77372613d6545383642bd9ed896';

/// See also [positionStream].
@ProviderFor(positionStream)
final positionStreamProvider = AutoDisposeStreamProvider<Position>.internal(
  positionStream,
  name: r'positionStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$positionStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PositionStreamRef = AutoDisposeStreamProviderRef<Position>;
String _$locationServiceHash() => r'7f060a527ada02cd823533d19ed11145ffe8b505';

/// See also [LocationService].
@ProviderFor(LocationService)
final locationServiceProvider =
    AutoDisposeAsyncNotifierProvider<LocationService, Position?>.internal(
  LocationService.new,
  name: r'locationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationService = AutoDisposeAsyncNotifier<Position?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
