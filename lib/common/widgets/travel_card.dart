import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 旅行先や旅行プランを表示するためのカードコンポーネント
class TravelCard extends StatelessWidget {
  const TravelCard({
    required this.title,
    required this.subtitle,
    super.key,
    this.imageGradient,
    this.imageUrl,
    this.price,
    this.icon,
    this.rating,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    this.tags = const [],
    this.animationDelay,
  });

  final String title;
  final String subtitle;
  final LinearGradient? imageGradient;
  final String? imageUrl;
  final String? price;
  final IconData? icon;
  final double? rating;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final List<String> tags;
  final Duration? animationDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget card = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 画像エリア
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: imageGradient ??
                    LinearGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.8),
                        Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.6),
                      ],
                    ),
              ),
              child: Stack(
                children: [
                  // お気に入りボタン
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.pink : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // アイコン
                  if (icon != null)
                    Center(
                      child: Icon(
                        icon,
                        size: 60,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  // 価格表示
                  if (price != null)
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          price!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // コンテンツエリア
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイトルと評価
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (rating != null) ...[
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating!.toStringAsFixed(1),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // サブタイトル
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // タグ
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: tags
                          .take(3)
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 12),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // アニメーション適用
    if (animationDelay != null) {
      card = card
          .animate(delay: animationDelay)
          .fadeIn(duration: const Duration(milliseconds: 600))
          .slideY(
            begin: 0.3,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
          );
    }

    return card;
  }
}

/// コンパクトなサイズの旅行カード
class CompactTravelCard extends StatelessWidget {
  const CompactTravelCard({
    required this.title,
    required this.subtitle,
    required this.color,
    super.key,
    this.icon,
    this.onTap,
    this.animationDelay,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;
  final Duration? animationDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget card = Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // アイコン
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 12),

              // テキスト情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 矢印アイコン
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );

    // アニメーション適用
    if (animationDelay != null) {
      card = card
          .animate(delay: animationDelay)
          .fadeIn(duration: const Duration(milliseconds: 400))
          .slideX(
            begin: 0.3,
            duration: const Duration(milliseconds: 600),
          );
    }

    return card;
  }
}
