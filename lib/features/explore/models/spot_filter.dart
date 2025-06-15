import 'package:world_travel/features/explore/models/spot.dart';

class SpotFilter {
  SpotFilter({
    this.categories = const [],
    this.distanceRange = DistanceRange.km3,
    this.sortOrder = SortOrder.likes,
    this.searchQuery = '',
  });

  final List<SpotCategory> categories;
  final DistanceRange distanceRange;
  final SortOrder sortOrder;
  final String searchQuery;

  SpotFilter copyWith({
    List<SpotCategory>? categories,
    DistanceRange? distanceRange,
    SortOrder? sortOrder,
    String? searchQuery,
  }) {
    return SpotFilter(
      categories: categories ?? this.categories,
      distanceRange: distanceRange ?? this.distanceRange,
      sortOrder: sortOrder ?? this.sortOrder,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters =>
      categories.isNotEmpty || searchQuery.isNotEmpty;
}