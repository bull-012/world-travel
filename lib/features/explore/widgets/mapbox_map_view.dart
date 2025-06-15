import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:world_travel/features/explore/models/spot.dart';

class MapBoxMapView extends HookConsumerWidget {
  const MapBoxMapView({
    super.key,
    required this.spots,
    required this.onSpotSelected,
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

    // MapBox token is already set in main.dart via MapboxOptions.setAccessToken()

    debugPrint('Creating MapWidget with token check...');
    debugPrint('Initial position: ${initialPosition?.latitude}, '
        '${initialPosition?.longitude}');
    debugPrint('Spots count: ${spots.length}');
    
    // Check MapBox token in effect
    useEffect(() {
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
    }, []);
    
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

    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
          MapWidget(
        key: ValueKey('map-${spots.length}'),
        cameraOptions: CameraOptions(
          center: Point(
            coordinates: Position(
              initialPosition?.longitude ?? 139.6917,
              initialPosition?.latitude ?? 35.6895,
            ),
          ),
          zoom: 14,
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
            await _initializeMap(controller, spots);
            isMapReady.value = true;
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
        ],
      ),
    );
  }

  Future<void> _initializeMap(MapboxMap controller, List<Spot> spots) async {
    try {
      debugPrint('Initializing MapBox map with ${spots.length} spots');
      
      // Skip marker addition for now to test basic map loading
      if (spots.isEmpty) {
        debugPrint('No spots to add');
        return;
      }
      
      // Add a single test marker first
      if (spots.isNotEmpty) {
        debugPrint('Adding test marker for first spot: ${spots.first.name}');
        await _addSpotMarker(controller, spots.first);
      }
      
      debugPrint('Map initialization completed');
    } on Exception catch (e) {
      debugPrint('Error initializing map: $e');
    }
  }

  Future<void> _addSpotMarker(MapboxMap controller, Spot spot) async {
    try {
      debugPrint('Adding marker for ${spot.name} at ${spot.location.latitude}, ${spot.location.longitude}');
      
      final point = Point(
        coordinates: Position(
          spot.location.longitude,
          spot.location.latitude,
        ),
      );

      // Create a simple point annotation
      final annotationManager = await controller.annotations
          .createPointAnnotationManager();
      
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

}
