import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:world_travel/features/explore/models/spot.dart';
import 'package:world_travel/features/explore/models/spot_filter.dart';
import 'package:world_travel/features/explore/providers/location_provider.dart';

part 'spots_provider.g.dart';

@riverpod
class SpotsFilter extends _$SpotsFilter {
  @override
  SpotFilter build() => SpotFilter();

  SpotFilter get filter => state;

  void updateCategories(List<SpotCategory> categories) {
    state = state.copyWith(categories: categories);
  }

  void updateDistanceRange(DistanceRange range) {
    state = state.copyWith(distanceRange: range);
  }

  void updateSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = SpotFilter();
  }
}

@riverpod
Future<List<Spot>> spots(Ref ref) async {
  final filter = ref.watch(spotsFilterProvider);
  // Don't wait for location, use it if available
  final positionAsync = ref.watch(locationServiceProvider);
  final position = positionAsync.valueOrNull;

  // Generate mock data for now
  final mockSpots = _generateMockSpots();

  // Apply filters
  var filteredSpots = mockSpots;

  // Filter by search query
  if (filter.searchQuery.isNotEmpty) {
    filteredSpots = filteredSpots.where((spot) {
      return spot.name
              .toLowerCase()
              .contains(filter.searchQuery.toLowerCase()) ||
          spot.address.toLowerCase().contains(filter.searchQuery.toLowerCase());
    }).toList();
  }

  // Filter by categories
  if (filter.categories.isNotEmpty) {
    filteredSpots = filteredSpots.where((spot) {
      return spot.category.any((category) {
        final spotCategory = SpotCategory.fromString(category);
        return filter.categories.contains(spotCategory);
      });
    }).toList();
  }

  // Filter by distance if location is available
  if (position != null) {
    filteredSpots = filteredSpots.where((spot) {
      final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            spot.location.latitude,
            spot.location.longitude,
          ) /
          1000; // Convert to kilometers

      return distance <= filter.distanceRange.kilometers;
    }).toList();
  }

  // Sort spots
  switch (filter.sortOrder) {
    case SortOrder.likes:
      filteredSpots.sort((a, b) => b.likes.compareTo(a.likes));
    case SortOrder.rating:
      filteredSpots.sort((a, b) => b.rating.compareTo(a.rating));
    case SortOrder.reviews:
      filteredSpots.sort((a, b) => b.reviews.count.compareTo(a.reviews.count));
    case SortOrder.distance:
      if (position != null) {
        filteredSpots.sort((a, b) {
          final distanceA = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            a.location.latitude,
            a.location.longitude,
          );
          final distanceB = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            b.location.latitude,
            b.location.longitude,
          );
          return distanceA.compareTo(distanceB);
        });
      }
  }

  return filteredSpots;
}

List<Spot> _generateMockSpots() {
  final random = Random();
  final spots = <Spot>[];

  // Tokyo center coordinates
  const centerLat = 35.6895;
  const centerLng = 139.6917;

  final spotData = [
    ('スターバックス 渋谷店', SpotCategory.cafe, '東京都渋谷区渋谷1-1-1'),
    ('一蘭ラーメン 原宿店', SpotCategory.restaurant, '東京都渋谷区神宮前1-1-1'),
    ('東京スカイツリー', SpotCategory.tourism, '東京都墨田区押上1-1-2'),
    ('渋谷PARCO', SpotCategory.shopping, '東京都渋谷区宇田川町15-1'),
    ('新宿御苑', SpotCategory.tourism, '東京都新宿区内藤町11'),
    ('ブルーボトルコーヒー 青山', SpotCategory.cafe, '東京都港区南青山3-13-14'),
    ('焼肉叙々苑 六本木', SpotCategory.restaurant, '東京都港区六本木6-1-1'),
    ('東京ディズニーランド', SpotCategory.entertainment, '千葉県浦安市舞浜1-1'),
    ('ドン・キホーテ 渋谷', SpotCategory.shopping, '東京都渋谷区宇田川町28-6'),
    ('ホテルニューオータニ', SpotCategory.hotel, '東京都千代田区紀尾井町4-1'),
  ];

  for (var i = 0; i < spotData.length; i++) {
    final (name, category, address) = spotData[i];

    // Generate random coordinates around Tokyo
    final lat = centerLat + (random.nextDouble() - 0.5) * 0.1;
    final lng = centerLng + (random.nextDouble() - 0.5) * 0.1;

    spots.add(
      Spot(
        id: 'spot_${i + 1}',
        name: name,
        address: address,
        category: [category.name],
        location: SpotLocation(
          latitude: lat,
          longitude: lng,
        ),
        rating: 3.5 + random.nextDouble() * 1.5,
        reviews: SpotReviews(
          count: random.nextInt(500) + 50,
          items: [],
        ),
        likes: random.nextInt(5000) + 100,
        media: SpotMedia(
          photos: [
            'https://picsum.photos/400/300?random=$i',
            'https://picsum.photos/400/300?random=${i + 10}',
          ],
          videos: [],
        ),
        details: SpotDetails(
          hours: {
            '月曜日': '10:00 - 22:00',
            '火曜日': '10:00 - 22:00',
            '水曜日': '10:00 - 22:00',
            '木曜日': '10:00 - 22:00',
            '金曜日': '10:00 - 23:00',
            '土曜日': '10:00 - 23:00',
            '日曜日': '10:00 - 21:00',
          },
          price: '¥¥',
          phone: '03-${random.nextInt(9000) + 1000}-'
              '${random.nextInt(9000) + 1000}',
          website: 'https://example.com',
        ),
      ),
    );
  }

  return spots;
}

@riverpod
Future<List<Spot>> rankedSpots(Ref ref) async {
  final spots = await ref.watch(spotsProvider.future);
  final filter = ref.watch(spotsFilterProvider);

  // Return spots sorted by the current sort order
  final sortedSpots = List<Spot>.from(spots);

  switch (filter.sortOrder) {
    case SortOrder.likes:
      sortedSpots.sort((a, b) => b.likes.compareTo(a.likes));
    case SortOrder.rating:
      sortedSpots.sort((a, b) => b.rating.compareTo(a.rating));
    case SortOrder.reviews:
      sortedSpots.sort((a, b) => b.reviews.count.compareTo(a.reviews.count));
    case SortOrder.distance:
      // Already sorted by distance in spots provider
      break;
  }

  // Return top 10 spots
  return sortedSpots.take(10).toList();
}
