import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/features/explore/models/spot.dart';
import 'package:world_travel/features/explore/providers/location_provider.dart';
import 'package:world_travel/features/explore/providers/spots_provider.dart';
import 'package:world_travel/features/explore/widgets/mapbox_map_view.dart';
import 'package:world_travel/features/explore/widgets/search_filter_bar.dart';
import 'package:world_travel/features/explore/widgets/spot_card.dart';
import 'package:world_travel/features/explore/widgets/spot_detail_sheet.dart';
import 'package:world_travel/features/explore/widgets/spot_ranking_list.dart';

class ExplorePage extends HookConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = useState<ViewMode>(ViewMode.map);
    final selectedSpot = useState<Spot?>(null);
    final spotsAsync = ref.watch(spotsProvider);
    final locationAsync = ref.watch(locationServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search and filter bar
            const SearchFilterBar(),

            // View mode toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _ViewModeButton(
                      icon: Icons.map,
                      label: '地図',
                      isSelected: viewMode.value == ViewMode.map,
                      onTap: () => viewMode.value = ViewMode.map,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ViewModeButton(
                      icon: Icons.list,
                      label: 'リスト',
                      isSelected: viewMode.value == ViewMode.list,
                      onTap: () => viewMode.value = ViewMode.list,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ViewModeButton(
                      icon: Icons.emoji_events,
                      label: 'ランキング',
                      isSelected: viewMode.value == ViewMode.ranking,
                      onTap: () => viewMode.value = ViewMode.ranking,
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Stack(
                children: [
                  // Map view (always rendered to maintain state)
                  if (viewMode.value == ViewMode.map)
                    switch (spotsAsync) {
                      AsyncData(:final value) => MapBoxMapView(
                          spots: value,
                          onSpotSelected: (spot) {
                            selectedSpot.value = spot;
                            SpotDetailSheet.show(context, spot);
                          },
                          initialPosition: locationAsync.valueOrNull,
                        ),
                      AsyncLoading() => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      AsyncError(:final error) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text('エラーが発生しました: $error'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.refresh(spotsProvider),
                                child: const Text('再試行'),
                              ),
                            ],
                          ),
                        ),
                      _ => const SizedBox.shrink(),
                    },

                  // List view
                  if (viewMode.value == ViewMode.list)
                    switch (spotsAsync) {
                      AsyncData(:final value) => ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            final spot = value[index];
                            return SpotCard(
                              spot: spot,
                              onTap: () => SpotDetailSheet.show(context, spot),
                              isSelected: selectedSpot.value?.id == spot.id,
                            );
                          },
                        ),
                      AsyncLoading() => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      AsyncError(:final error) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text('エラーが発生しました: $error'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.refresh(spotsProvider),
                                child: const Text('再試行'),
                              ),
                            ],
                          ),
                        ),
                      _ => const SizedBox.shrink(),
                    },

                  // Ranking view
                  if (viewMode.value == ViewMode.ranking)
                    const SingleChildScrollView(
                      child: SpotRankingList(),
                    ),

                  // Location permission prompt - only show when loaded and
                  // permission denied
                  if (!locationAsync.isLoading &&
                      (locationAsync.hasError || locationAsync.value == null))
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_off,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '位置情報が無効です',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '現在地周辺のスポットを表示するには位置情報を有効にしてください',
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () async {
                                  // Request location permission
                                  await ref
                                      .read(locationServiceProvider.notifier)
                                      .requestLocationPermission();

                                  // Refresh location provider to check status
                                  // ignore: unused_result
                                  ref.refresh(locationServiceProvider);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                child: const Text('有効にする'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ViewMode { map, list, ranking }

class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Theme.of(context).primaryColor
          : Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
