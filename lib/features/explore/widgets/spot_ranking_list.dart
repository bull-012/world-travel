import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/features/explore/providers/spots_provider.dart';
import 'package:world_travel/features/explore/widgets/spot_card.dart';
import 'package:world_travel/features/explore/widgets/spot_detail_sheet.dart';

class SpotRankingList extends ConsumerWidget {
  const SpotRankingList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankedSpotsAsync = ref.watch(rankedSpotsProvider);
    final filter = ref.watch(spotsFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                'ランキング TOP10',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                filter.sortOrder.displayName,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Ranking list
        switch (rankedSpotsAsync) {
          AsyncData(:final value) when value.isEmpty => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('スポットが見つかりませんでした'),
              ),
            ),
          AsyncData(:final value) => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value.length,
              itemBuilder: (context, index) {
                final spot = value[index];
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: SpotCard(
                        spot: spot,
                        onTap: () => SpotDetailSheet.show(context, spot),
                      ),
                    ),
                    // Ranking badge
                    Positioned(
                      left: 16,
                      top: 24,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getRankingColor(index),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getRankingColor(index)
                                  .withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          AsyncLoading() => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
          AsyncError(:final error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
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
                      onPressed: () => ref.refresh(rankedSpotsProvider),
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ],
    );
  }

  Color _getRankingColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey[600]!;
      case 2:
        return Colors.brown[600]!;
      default:
        return Colors.blue;
    }
  }
}
