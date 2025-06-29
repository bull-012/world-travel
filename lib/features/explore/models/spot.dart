import 'package:collection/collection.dart';

class Spot {
  Spot({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.likes,
    required this.media,
    required this.details,
  });

  final String id;
  final String name;
  final String address;
  final List<String> category;
  final SpotLocation location;
  final double rating;
  final SpotReviews reviews;
  final int likes;
  final SpotMedia media;
  final SpotDetails details;

  Spot copyWith({
    String? id,
    String? name,
    String? address,
    List<String>? category,
    SpotLocation? location,
    double? rating,
    SpotReviews? reviews,
    int? likes,
    SpotMedia? media,
    SpotDetails? details,
  }) {
    return Spot(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      category: category ?? this.category,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      likes: likes ?? this.likes,
      media: media ?? this.media,
      details: details ?? this.details,
    );
  }
}

class SpotLocation {
  SpotLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class SpotReviews {
  SpotReviews({
    required this.count,
    required this.items,
  });

  final int count;
  final List<Review> items;
}

class Review {
  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
}

class SpotMedia {
  SpotMedia({
    required this.photos,
    required this.videos,
  });

  final List<String> photos;
  final List<String> videos;
}

class SpotDetails {
  SpotDetails({
    required this.hours,
    required this.price,
    required this.phone,
    required this.website,
  });

  final Map<String, String> hours;
  final String price;
  final String phone;
  final String website;
}

enum SpotCategory {
  restaurant('レストラン'),
  cafe('カフェ'),
  tourism('観光地'),
  shopping('ショッピング'),
  entertainment('エンターテイメント'),
  hotel('ホテル'),
  other('その他');

  const SpotCategory(this.displayName);
  final String displayName;

  static SpotCategory fromString(String category) {
    return SpotCategory.values.firstWhereOrNull(
          (e) => e.name == category || e.displayName == category,
        ) ??
        SpotCategory.other;
  }
}

enum DistanceRange {
  m500('500m', 0.5),
  km1('1km', 1),
  km3('3km', 3),
  km5('5km', 5),
  km10('10km', 10);

  const DistanceRange(this.displayName, this.kilometers);
  final String displayName;
  final double kilometers;
}

enum SortOrder {
  likes('いいね数'),
  rating('評価'),
  reviews('レビュー数'),
  distance('距離');

  const SortOrder(this.displayName);
  final String displayName;
}
