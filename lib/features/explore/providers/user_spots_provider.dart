import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:world_travel/features/explore/models/spot.dart';

part 'user_spots_provider.g.dart';

// Model for user-created spots
class UserSpot {
  UserSpot({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory UserSpot.fromMap(Map<String, dynamic> map) {
    return UserSpot(
      id: map['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      category: map['category'] as String,
      rating: map['rating'] as double,
      comment: map['comment'] as String,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String category;
  final double rating;
  final String comment;
  final DateTime createdAt;

  UserSpot copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? category,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return UserSpot(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Spot toSpot() {
    return Spot(
      id: id,
      name: name,
      address: '緯度: $latitude, 経度: $longitude',
      category: [category],
      location: SpotLocation(
        latitude: latitude,
        longitude: longitude,
      ),
      rating: rating,
      reviews: SpotReviews(
        count: 1,
        items: [
          Review(
            id: '1',
            userId: 'user',
            userName: 'あなた',
            rating: rating,
            comment: comment,
            createdAt: createdAt,
          ),
        ],
      ),
      likes: 0,
      media: SpotMedia(
        photos: [],
        videos: [],
      ),
      details: SpotDetails(
        hours: {},
        price: '',
        phone: '',
        website: '',
      ),
    );
  }
}

@Riverpod(keepAlive: true)
class UserSpotsNotifier extends _$UserSpotsNotifier {
  @override
  List<UserSpot> build() {
    // Initialize with empty list
    // In a real app, this would load from local storage or API
    return [];
  }

  void addSpot(Map<String, dynamic> spotData) {
    final newSpot = UserSpot.fromMap({
      ...spotData,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    });
    state = [...state, newSpot];
  }

  void removeSpot(String id) {
    state = state.where((spot) => spot.id != id).toList();
  }

  void updateSpot(String id, Map<String, dynamic> updates) {
    state = state.map((spot) {
      if (spot.id == id) {
        final updatedMap = spot.toMap()..addAll(updates);
        return UserSpot.fromMap(updatedMap);
      }
      return spot;
    }).toList();
  }
}

// Provider to get user spots as Spot objects for display
@riverpod
List<Spot> userSpotsAsSpots(Ref ref) {
  final userSpots = ref.watch(userSpotsNotifierProvider);
  return userSpots.map((UserSpot userSpot) => userSpot.toSpot()).toList();
}
