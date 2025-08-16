import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:world_travel/features/explore/widgets/mapbox_map_view.dart';

class ReviewPostingSheet extends HookWidget {
  const ReviewPostingSheet({
    required this.spot,
    required this.onReviewPosted,
    super.key,
  });

  final TemporarySpot spot;
  final void Function(Map<String, dynamic>) onReviewPosted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameController = useTextEditingController(text: spot.name);
    final commentController = useTextEditingController();
    final rating = useState<double>(4);
    final selectedCategory = useState<String>(spot.category);
    final isPosting = useState<bool>(false);

    final categories = [
      'レストラン',
      'カフェ',
      '観光地',
      'ショッピング',
      'エンターテイメント',
      'ホテル',
      'その他',
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
                Expanded(
                  child: Text(
                    '新しいスポットを追加',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: isPosting.value
                      ? null
                      : () async {
                          if (nameController.text.isEmpty ||
                              commentController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('名前とコメントを入力してください'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          isPosting.value = true;

                          // Simulate posting delay
                          await Future<void>.delayed(
                            const Duration(seconds: 1),
                          );

                          final review = {
                            'name': nameController.text,
                            'category': selectedCategory.value,
                            'rating': rating.value,
                            'comment': commentController.text,
                            'latitude': spot.latitude,
                            'longitude': spot.longitude,
                            'createdAt': DateTime.now().toIso8601String(),
                          };

                          onReviewPosted(review);
                        },
                  child: isPosting.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('投稿'),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '座標',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${spot.latitude.toStringAsFixed(6)}, '
                                '${spot.longitude.toStringAsFixed(6)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Spot name
                  Text(
                    'スポット名',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'スポットの名前を入力',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Category
                  Text(
                    'カテゴリー',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = selectedCategory.value == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            selectedCategory.value = category;
                          }
                        },
                        selectedColor: theme.colorScheme.primaryContainer,
                        backgroundColor:
                            theme.colorScheme.surface.withValues(alpha: 0.8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Rating
                  Text(
                    '評価',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        IconButton(
                          onPressed: () => rating.value = i.toDouble(),
                          icon: Icon(
                            i <= rating.value ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        ),
                      const SizedBox(width: 16),
                      Text(
                        rating.value.toInt().toString(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Comment
                  Text(
                    'コメント',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'このスポットについての感想や情報を入力',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Photo upload placeholder
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surface,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '写真を追加（今後実装予定）',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
