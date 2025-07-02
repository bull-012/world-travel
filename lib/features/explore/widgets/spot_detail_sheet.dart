import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_travel/features/explore/models/spot.dart';

class SpotDetailSheet extends ConsumerWidget {
  const SpotDetailSheet({
    required this.spot,
    super.key,
  });

  final Spot spot;

  static void show(BuildContext context, Spot spot) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SpotDetailSheet(spot: spot),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Images
                      if (spot.media.photos.isNotEmpty) ...[
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            itemCount: spot.media.photos.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: spot.media.photos[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => ColoredBox(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        ColoredBox(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      child:
                                          const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Name and category
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              spot.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(spot.category.first)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              SpotCategory.fromString(spot.category.first)
                                  .displayName,
                              style: TextStyle(
                                fontSize: 14,
                                color: _getCategoryColor(spot.category.first),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Address
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              spot.address,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.star,
                            iconColor: Colors.orange,
                            value: spot.rating.toStringAsFixed(1),
                            label: '評価',
                          ),
                          _StatItem(
                            icon: Icons.comment,
                            iconColor: Colors.blue,
                            value: '${spot.reviews.count}',
                            label: 'レビュー',
                          ),
                          _StatItem(
                            icon: Icons.favorite,
                            iconColor: Colors.red,
                            value: '${spot.likes}',
                            label: 'いいね',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Details section
                      _DetailSection(
                        title: '営業時間',
                        icon: Icons.access_time,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: spot.details.hours.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text(entry.value),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact info
                      _DetailSection(
                        title: '連絡先',
                        icon: Icons.contact_phone,
                        child: Column(
                          children: [
                            if (spot.details.phone.isNotEmpty)
                              ListTile(
                                leading: const Icon(Icons.phone),
                                title: Text(spot.details.phone),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () =>
                                    _launchUrl('tel:${spot.details.phone}'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            if (spot.details.website.isNotEmpty)
                              ListTile(
                                leading: const Icon(Icons.language),
                                title: const Text('ウェブサイト'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _launchUrl(spot.details.website),
                                contentPadding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement route navigation
                              },
                              icon: const Icon(Icons.directions),
                              label: const Text('経路案内'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Implement favorite
                              },
                              icon: const Icon(Icons.favorite_border),
                              label: const Text('お気に入り'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Color _getCategoryColor(String categoryName) {
    final category = SpotCategory.fromString(categoryName);
    switch (category) {
      case SpotCategory.restaurant:
        return Colors.orange;
      case SpotCategory.cafe:
        return Colors.brown;
      case SpotCategory.tourism:
        return Colors.blue;
      case SpotCategory.shopping:
        return Colors.purple;
      case SpotCategory.entertainment:
        return Colors.pink;
      case SpotCategory.hotel:
        return Colors.teal;
      case SpotCategory.other:
        return Colors.grey;
    }
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
