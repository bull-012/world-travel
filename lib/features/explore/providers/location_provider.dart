import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_provider.g.dart';

@riverpod
class LocationService extends _$LocationService {
  @override
  Future<Position?> build() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );
    } on Exception {
      return null;
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, ask user to enable it
      return false;
    }

    // Check permission status using Geolocator
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try requesting again
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      await Geolocator.openAppSettings();
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device
    return true;
  }

  Future<void> requestLocationPermission() async {
    final hasPermission = await _handleLocationPermission();
    if (hasPermission) {
      // Refresh the location
      ref.invalidateSelf();
    }
  }

  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );
  }
}

@riverpod
Stream<Position> positionStream(Ref ref) async* {
  final locationService = ref.watch(locationServiceProvider.notifier);

  // First check permissions
  final currentPosition = await ref.watch(locationServiceProvider.future);
  if (currentPosition == null) {
    return;
  }

  // Then start streaming position updates
  yield* locationService.watchPosition();
}
