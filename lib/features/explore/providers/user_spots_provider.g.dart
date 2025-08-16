// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_spots_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userSpotsAsSpotsHash() => r'2256e585cbf61de5961e151934a51c57601006d3';

/// See also [userSpotsAsSpots].
@ProviderFor(userSpotsAsSpots)
final userSpotsAsSpotsProvider = AutoDisposeProvider<List<Spot>>.internal(
  userSpotsAsSpots,
  name: r'userSpotsAsSpotsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userSpotsAsSpotsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserSpotsAsSpotsRef = AutoDisposeProviderRef<List<Spot>>;
String _$userSpotsNotifierHash() => r'67e0cef30780f8485fec992e9ae7439d20c37870';

/// See also [UserSpotsNotifier].
@ProviderFor(UserSpotsNotifier)
final userSpotsNotifierProvider =
    NotifierProvider<UserSpotsNotifier, List<UserSpot>>.internal(
  UserSpotsNotifier.new,
  name: r'userSpotsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userSpotsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserSpotsNotifier = Notifier<List<UserSpot>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
