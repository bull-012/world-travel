import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:world_travel/common/widgets/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Travel'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知機能を開発中')),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ウェルカムセクション
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'こんにちは！',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '次の冒険を始めよう',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.flight_takeoff,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '15カ国訪問済み',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 600))
                .slideY(begin: 0.3, duration: const Duration(milliseconds: 800))
                .shimmer(delay: const Duration(milliseconds: 1000)),
          ),

          // クイックアクションセクション
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'クイックアクション',
                    style: theme.textTheme.headlineMedium,
                  )
                      .animate(delay: const Duration(milliseconds: 200))
                      .fadeIn(duration: const Duration(milliseconds: 400))
                      .slideX(begin: -0.2),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.add_location_outlined,
                          title: '新しい旅行',
                          subtitle: 'プランを作成',
                          color: theme.colorScheme.primary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('新しい旅行プラン作成')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.map_outlined,
                          title: 'マップ表示',
                          subtitle: '世界地図を見る',
                          color: theme.colorScheme.secondary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('世界地図を表示')),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                      .animate(delay: const Duration(milliseconds: 400))
                      .fadeIn(duration: const Duration(milliseconds: 600))
                      .slideY(begin: 0.2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.camera_alt_outlined,
                          title: '思い出',
                          subtitle: '写真を見る',
                          color: Colors.purple,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('思い出の写真')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.people_outline,
                          title: 'コミュニティ',
                          subtitle: '旅行者と交流',
                          color: Colors.green,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('コミュニティ機能')),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                      .animate(delay: const Duration(milliseconds: 600))
                      .fadeIn(duration: const Duration(milliseconds: 600))
                      .slideY(begin: 0.2),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 最近の活動セクション
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '最近の活動',
                        style: theme.textTheme.headlineMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('すべての活動を表示')),
                          );
                        },
                        child: const Text('すべて表示'),
                      ),
                    ],
                  )
                      .animate(delay: const Duration(milliseconds: 800))
                      .fadeIn(duration: const Duration(milliseconds: 400)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 活動リスト
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final activity = _recentActivities[index];
                  return ActivityCard(
                    title: activity['title'] as String,
                    subtitle: activity['subtitle'] as String,
                    icon: activity['icon'] as IconData,
                    color: activity['color'] as Color,
                    time: activity['time'] as String,
                    animationDelay: Duration(milliseconds: 1000 + (index * 100)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${activity['title']}の詳細'),
                        ),
                      );
                    },
                  );
                },
                childCount: _recentActivities.length,
              ),
            ),
          ),

          // 底部パディング
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// サンプル活動データ
final List<Map<String, dynamic>> _recentActivities = [
  {
    'icon': Icons.flight_takeoff,
    'title': '東京への旅行',
    'subtitle': '3日間の旅行プランを作成しました',
    'time': '2時間前',
    'color': Colors.blue,
  },
  {
    'icon': Icons.favorite,
    'title': 'パリの観光地',
    'subtitle': 'エッフェル塔をお気に入りに追加',
    'time': '5時間前',
    'color': Colors.pink,
  },
  {
    'icon': Icons.photo_camera,
    'title': '京都の写真',
    'subtitle': '清水寺の写真を15枚アップロード',
    'time': '昨日',
    'color': Colors.green,
  },
  {
    'icon': Icons.group,
    'title': '旅行グループ',
    'subtitle': '「ヨーロッパ旅行2024」に参加',
    'time': '2日前',
    'color': Colors.orange,
  },
  {
    'icon': Icons.star,
    'title': 'レビュー投稿',
    'subtitle': '大阪城のレビューを投稿',
    'time': '3日前',
    'color': Colors.amber,
  },
];
