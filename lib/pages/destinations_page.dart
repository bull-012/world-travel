import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DestinationsPage extends StatelessWidget {
  const DestinationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('目的地'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // フィル機能
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
                      child: _buildStatCard(
                        context,
                        '訪問済み',
                        '15',
                        Icons.check_circle,
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '予定',
                        '8',
                        Icons.schedule,
                        theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'お気に入り',
                        '23',
                        Icons.favorite,
                        Colors.pink,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 600))
                    .slideY(begin: 0.2),
                
                const SizedBox(height: 24),
                
                // セクションタイトル
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '人気の目的地',
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
          
          // 目的地リスト
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final destination = _destinations[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 画像プレースホルダー
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  destination['color'] as Color,
                                  (destination['color'] as Color).withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      destination['isFavorite'] as bool 
                                          ? Icons.favorite 
                                          : Icons.favorite_border,
                                      color: destination['isFavorite'] as bool 
                                          ? Colors.pink 
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Icon(
                                    destination['icon'] as IconData,
                                    size: 60,
                                    color: Colors.white.withOpacity(0.8),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        destination['name'] as String,
                                        style: theme.textTheme.titleLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          destination['rating'].toString(),
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  destination['location'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  destination['description'] as String,
                                  style: theme.textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                        destination['category'] as String,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      materialTapTargetSize: 
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    const Spacer(),
                                    FilledButton.tonal(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${destination['name']}の詳細を表示',
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
                childCount: _destinations.length,
              ),
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

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// サンプル目的地データ
final List<Map<String, dynamic>> _destinations = [
  {
    'name': '東京タワー',
    'location': '東京, 日本',
    'description': '東京のシンボルとして親しまれている赤い電波塔。展望台からの景色は絶景です。',
    'rating': 4.3,
    'category': '観光地',
    'icon': Icons.tower,
    'color': Colors.red,
    'isFavorite': true,
  },
  {
    'name': 'エッフェル塔',
    'location': 'パリ, フランス',
    'description': 'パリの象徴的な鉄塔。夜のライトアップは特にロマンチックです。',
    'rating': 4.5,
    'category': '名所',
    'icon': Icons.tower,
    'color': Colors.brown,
    'isFavorite': false,
  },
  {
    'name': 'グランドキャニオン',
    'location': 'アリゾナ, アメリカ',
    'description': '壮大な大自然の景観。地球の歴史を感じることができる圧倒的な峡谷です。',
    'rating': 4.7,
    'category': '自然',
    'icon': Icons.landscape,
    'color': Colors.orange,
    'isFavorite': true,
  },
  {
    'name': 'サントリーニ島',
    'location': 'ギリシャ',
    'description': '青い海と白い建物のコントラストが美しいエーゲ海の島。',
    'rating': 4.6,
    'category': 'リゾート',
    'icon': Icons.beach_access,
    'color': Colors.blue,
    'isFavorite': false,
  },
  {
    'name': 'マチュピチュ',
    'location': 'ペルー',
    'description': '空中都市として知られる古代インカの遺跡。神秘的な雰囲気に包まれています。',
    'rating': 4.8,
    'category': '世界遺産',
    'icon': Icons.museum,
    'color': Colors.green,
    'isFavorite': true,
  },
];