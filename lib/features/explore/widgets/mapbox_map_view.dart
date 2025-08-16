import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:world_travel/features/explore/models/spot.dart';
import 'package:world_travel/features/explore/providers/user_spots_provider.dart';

class MapBoxMapView extends HookConsumerWidget {
  const MapBoxMapView({
    required this.spots,
    required this.onSpotSelected,
    super.key,
    this.initialPosition,
  });

  final List<Spot> spots;
  final void Function(Spot) onSpotSelected;
  final geo.Position? initialPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapController = useState<MapboxMap?>(null);
    final isMapReady = useState(false);
    final hasError = useState<String?>(null);
    final buildContext = useContext();
    final userSpots = ref.watch(userSpotsNotifierProvider);

    // MapBox token is already set in main.dart via
    // MapboxOptions.setAccessToken()

    debugPrint('Creating MapWidget with token check...');
    debugPrint('Initial position: ${initialPosition?.latitude}, '
        '${initialPosition?.longitude}');
    debugPrint('Spots count: ${spots.length}');

    // Check MapBox token in effect
    useEffect(
      () {
        MapboxOptions.getAccessToken().then((token) {
          debugPrint('MapBox Access Token available: ${token.isNotEmpty}');
          debugPrint('Token starts with: '
              '${token.isNotEmpty ? token.substring(0, 10) : "NO TOKEN"}');
          if (token.isEmpty) {
            hasError.value = 'MapBox access token not set';
          }
        }).catchError((dynamic e) {
          debugPrint('Error getting MapBox token: $e');
          hasError.value = 'Failed to get MapBox token: $e';
        });
        return null;
      },
      [],
    );

    if (hasError.value != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Map Error: ${hasError.value}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SizedBox.expand(
      child: Stack(
        children: [
          MapWidget(
            key: ValueKey('map-${spots.length}'),
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  initialPosition?.longitude ?? 139.7265, // Roppongi area
                  initialPosition?.latitude ?? 35.6628, // Roppongi area
                ),
              ),
              zoom: 15,
              pitch: 0,
              bearing: 0,
            ),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            onMapCreated: (controller) async {
              debugPrint('MapBox onMapCreated called');
              mapController.value = controller;

              try {
                // Initialize map after small delay to ensure style is loaded
                await Future<void>.delayed(const Duration(milliseconds: 500));
                if (context.mounted) {
                  await _initializeMap(
                    controller,
                    spots,
                    userSpots,
                    buildContext,
                  );
                  isMapReady.value = true;
                }
              } on Exception catch (e) {
                debugPrint('Error in onMapCreated: $e');
                hasError.value = 'Failed to initialize map: $e';
              }
            },
            onStyleLoadedListener: (styleLoadedEventData) {
              debugPrint('MapBox style loaded successfully');
            },
            onMapLoadErrorListener: (mapLoadErrorEventData) {
              debugPrint('MapBox load error: ${mapLoadErrorEventData.message}');
              debugPrint('MapBox error type: ${mapLoadErrorEventData.type}');
              hasError.value = 'Map failed to load: '
                  '${mapLoadErrorEventData.message}';
            },
            onMapLoadedListener: (mapLoadedEventData) {
              debugPrint('MapBox map loaded successfully');
            },
          ),
          if (!isMapReady.value)
            const Center(
              child: CircularProgressIndicator(),
            ),
          // Add spot button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('地図をタップして新しいスポットを追加する機能は開発中です'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add_location_alt),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeMap(
    MapboxMap controller,
    List<Spot> spots,
    List<UserSpot> userSpots,
    BuildContext context,
  ) async {
    try {
      debugPrint('Initializing MapBox map with ${spots.length} spots');

      // Create annotation managers
      final pointAnnotationManager =
          await controller.annotations.createPointAnnotationManager();
      final circleAnnotationManager =
          await controller.annotations.createCircleAnnotationManager();

      // Add temporary pins in Roppongi/Nishi-Azabu area
      final temporarySpots = [
        TemporarySpot(
          name: '六本木ヒルズ',
          latitude: 35.6604,
          longitude: 139.7292,
          category: 'ショッピング',
        ),
        TemporarySpot(
          name: '六本木交差点',
          latitude: 35.6628,
          longitude: 139.7314,
          category: '観光地',
        ),
        TemporarySpot(
          name: '西麻布交差点',
          latitude: 35.6577,
          longitude: 139.7216,
          category: '観光地',
        ),
        TemporarySpot(
          name: 'GONPACHI 西麻布',
          latitude: 35.6574,
          longitude: 139.7206,
          category: 'レストラン',
        ),
        TemporarySpot(
          name: '青山霊園',
          latitude: 35.6659,
          longitude: 139.7203,
          category: '観光地',
        ),
      ];

      // Add temporary spots as markers
      for (final tempSpot in temporarySpots) {
        await _addTemporarySpotMarker(
          pointAnnotationManager,
          circleAnnotationManager,
          tempSpot,
        );
      }

      // Add existing spots
      for (final spot in spots) {
        await _addSpotMarker(controller, spot);
      }

      // Add user-created spots
      for (final userSpot in userSpots) {
        await _addUserSpotMarker(
          pointAnnotationManager,
          circleAnnotationManager,
          userSpot,
        );
      }

      // Annotation click handlers available on managers
      // The API uses addClickListener for annotations

      debugPrint('Map initialization completed');
    } on Exception catch (e) {
      debugPrint('Error initializing map: $e');
    }
  }

  Future<void> _addSpotMarker(MapboxMap controller, Spot spot) async {
    try {
      debugPrint(
        'Adding marker for ${spot.name} at '
        '${spot.location.latitude}, ${spot.location.longitude}',
      );

      final point = Point(
        coordinates: Position(
          spot.location.longitude,
          spot.location.latitude,
        ),
      );

      // Create a simple point annotation
      final annotationManager =
          await controller.annotations.createPointAnnotationManager();

      await annotationManager.create(
        PointAnnotationOptions(
          geometry: point,
          textField: spot.name,
          textSize: 14,
          textColor: Colors.black.toARGB32(),
          textHaloWidth: 2,
          textHaloColor: Colors.white.toARGB32(),
        ),
      );

      debugPrint('Successfully added marker for ${spot.name}');
    } on Exception catch (e) {
      debugPrint('Error adding marker for ${spot.name}: $e');
    }
  }

  Future<void> _addTemporarySpotMarker(
    PointAnnotationManager pointManager,
    CircleAnnotationManager circleManager,
    TemporarySpot tempSpot,
  ) async {
    try {
      final point = Point(
        coordinates: Position(
          tempSpot.longitude,
          tempSpot.latitude,
        ),
      );

      // Add a circle marker for temporary spots
      await circleManager.create(
        CircleAnnotationOptions(
          geometry: point,
          circleRadius: 8,
          circleColor: _getCategoryColor(tempSpot.category).toARGB32(),
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 2,
        ),
      );

      // Add text label
      await pointManager.create(
        PointAnnotationOptions(
          geometry: point,
          textField: tempSpot.name,
          textSize: 12,
          textColor: Colors.black.toARGB32(),
          textHaloWidth: 2,
          textHaloColor: Colors.white.toARGB32(),
          textOffset: [0, 1.5],
          textAnchor: TextAnchor.TOP,
        ),
      );

      debugPrint('Added temporary marker for ${tempSpot.name}');
    } on Exception catch (e) {
      debugPrint('Error adding temporary marker: $e');
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'レストラン':
        return Colors.orange;
      case 'カフェ':
        return Colors.brown;
      case '観光地':
        return Colors.blue;
      case 'ショッピング':
        return Colors.purple;
      case 'エンターテイメント':
        return Colors.red;
      case 'ホテル':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _addUserSpotMarker(
    PointAnnotationManager pointManager,
    CircleAnnotationManager circleManager,
    UserSpot userSpot,
  ) async {
    try {
      final point = Point(
        coordinates: Position(
          userSpot.longitude,
          userSpot.latitude,
        ),
      );

      // Add a special marker for user spots
      await circleManager.create(
        CircleAnnotationOptions(
          geometry: point,
          circleRadius: 10,
          circleColor: Colors.red.toARGB32(),
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 3,
        ),
      );

      // Add text label with rating
      await pointManager.create(
        PointAnnotationOptions(
          geometry: point,
          textField: '${userSpot.name}\n★${userSpot.rating.toInt()}',
          textSize: 12,
          textColor: Colors.black.toARGB32(),
          textHaloWidth: 2,
          textHaloColor: Colors.white.toARGB32(),
          textOffset: [0, 2],
          textAnchor: TextAnchor.TOP,
          textMaxWidth: 10,
        ),
      );

      debugPrint('Added user spot marker for ${userSpot.name}');
    } on Exception catch (e) {
      debugPrint('Error adding user spot marker: $e');
    }
  }
}

class TemporarySpot {
  TemporarySpot({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String category;
}
