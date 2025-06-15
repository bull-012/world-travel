import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:world_travel/common/widgets/index.dart';

class DestinationsPage extends StatelessWidget {
  const DestinationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('旅の計画'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // 新しい旅行計画を作成
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('新しい旅行計画を作成（機能準備中）')),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 統計セクション
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: '進行中',
                        value: '3',
                        icon: Icons.edit_calendar,
                        color: theme.colorScheme.primary,
                        animationDelay: const Duration(milliseconds: 200),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: '完了済み',
                        value: '12',
                        icon: Icons.check_circle,
                        color: theme.colorScheme.secondary,
                        animationDelay: const Duration(milliseconds: 400),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: StatCard(
                        title: '保存済み',
                        value: '8',
                        icon: Icons.bookmark,
                        color: Colors.orange,
                        animationDelay: Duration(milliseconds: 600),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 600))
                    .slideY(begin: 0.2),

                const SizedBox(height: 24),

                // クイックアクションセクション
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '新しい旅を始めよう',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '旅行計画を立てて、素晴らしい冒険に出かけましょう',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('新しい計画を作成（機能準備中）')),
                            );
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add),
                              SizedBox(width: 8),
                              Text('新しい計画を作成'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // セクションタイトル
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '進行中の旅行計画',
                      style: theme.textTheme.headlineMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        // すべて表示
                      },
                      child: const Text('すべて表示'),
                    ),
                  ],
                )
                    .animate(delay: const Duration(milliseconds: 200))
                    .fadeIn(duration: const Duration(milliseconds: 400)),

                const SizedBox(height: 16),
              ]),
            ),
          ),

          // 旅行プランリスト
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final plan = _travelPlans[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ヘッダー部分
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  plan['color'] as Color,
                                  (plan['color'] as Color)
                                      .withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                // ステータスバッジ
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      plan['status'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                // アイコン
                                Center(
                                  child: Icon(
                                    plan['icon'] as IconData,
                                    size: 50,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                // 進捗バー（下部）
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: LinearProgressIndicator(
                                    value: plan['progress'] as double,
                                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                                    minHeight: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // タイトルと期間
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        plan['title'] as String,
                                        style: theme.textTheme.titleLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        plan['duration'] as String,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // 目的地と日程
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: theme.colorScheme.outline,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        plan['destination'] as String,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${plan['startDate']} - ${plan['endDate']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // 説明
                                Text(
                                  plan['description'] as String,
                                  style: theme.textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                // 下部情報とアクション
                                Row(
                                  children: [
                                    // 予算と参加者
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plan['budget'] as String,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        Text(
                                          '${plan['participants']}名参加',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    // アクションボタン
                                    FilledButton.tonal(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${plan['title']}の詳細を表示',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('詳細'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate(delay: Duration(milliseconds: 100 * index))
                      .fadeIn(duration: const Duration(milliseconds: 600))
                      .slideY(
                        begin: 0.3,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                      );
                },
                childCount: _travelPlans.length,
              ),
            ),
          ),

          // テンプレート計画セクション
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  '人気のテンプレート',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.weekend,
                                size: 40,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '週末旅行',
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '2-3日間',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.beach_access,
                                size: 40,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'リゾート旅行',
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '5-7日間',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),

          // 底部パディング
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 100),
          ),
        ],
      ),
    );
  }
}

// サンプル旅行プランデータ
final List<Map<String, dynamic>> _travelPlans = [
  {
    'title': '春の京都桜巡りツアー',
    'destination': '京都, 日本',
    'description': '古都京都の美しい桜を巡る3日間の旅。清水寺、金閣寺、嵐山を訪問予定。',
    'duration': '3日間',
    'startDate': '2024年4月5日',
    'endDate': '2024年4月7日',
    'status': '進行中',
    'progress': 0.7,
    'category': '文化・歴史',
    'icon': Icons.temple_buddhist,
    'color': Colors.pink,
    'budget': '¥85,000',
    'participants': 2,
  },
  {
    'title': 'パリ美術館巡りの旅',
    'destination': 'パリ, フランス',
    'description': 'ルーヴル美術館、オルセー美術館を中心としたアート鑑賞の旅。',
    'duration': '5日間',
    'startDate': '2024年6月15日',
    'endDate': '2024年6月19日',
    'status': '計画中',
    'progress': 0.4,
    'category': 'アート・文化',
    'icon': Icons.museum,
    'color': Colors.purple,
    'budget': '¥320,000',
    'participants': 1,
  },
  {
    'title': 'ハワイリゾート満喫プラン',
    'destination': 'ハワイ, アメリカ',
    'description': 'ワイキキビーチでのんびり過ごす癒しの休暇。ダイヤモンドヘッド登山も予定。',
    'duration': '7日間',
    'startDate': '2024年8月10日',
    'endDate': '2024年8月16日',
    'status': '計画中',
    'progress': 0.2,
    'category': 'リゾート・ビーチ',
    'icon': Icons.beach_access,
    'color': Colors.blue,
    'budget': '¥450,000',
    'participants': 4,
  },
  {
    'title': '北欧オーロラ観測ツアー',
    'destination': 'フィンランド・ノルウェー',
    'description': '神秘的なオーロラを観測する特別な旅。サーミ文化体験も含まれます。',
    'duration': '6日間',
    'startDate': '2025年1月20日',
    'endDate': '2025年1月25日',
    'status': '保存済み',
    'progress': 0.1,
    'category': '自然・アドベンチャー',
    'icon': Icons.nightlight,
    'color': Colors.green,
    'budget': '¥380,000',
    'participants': 2,
  },
];
