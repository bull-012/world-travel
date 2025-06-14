import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('探索'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 検索機能を実装予定
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
                // ヒーローセクション
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Icon(
                          Icons.explore,
                          size: 120,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '新しい発見を',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '世界中の素晴らしい場所を探索しよう',
                              style: TextStyle(
                                fontSize: 16,
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
                    .slideY(
                      begin: 0.3,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                    ),
                
                const SizedBox(height: 24),
                
                // カテゴリセクション
                Text(
                  'カテゴリ',
                  style: theme.textTheme.headlineMedium,
                )
                    .animate(delay: const Duration(milliseconds: 200))
                    .fadeIn(duration: const Duration(milliseconds: 400))
                    .slideX(begin: -0.2),
                
                const SizedBox(height: 16),
                
                // カテゴリグリッド
                ...List.generate(
                  _categories.length,
                  (index) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _categories[index]['icon'] as IconData,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(_categories[index]['title'] as String),
                        subtitle: Text(_categories[index]['subtitle'] as String),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${_categories[index]['title']}を開発中',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                      .animate(delay: Duration(milliseconds: 100 * index))
                      .fadeIn(duration: const Duration(milliseconds: 400))
                      .slideX(
                        begin: 0.3,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                      ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// カテゴリデータ
final List<Map<String, dynamic>> _categories = [
  {
    'icon': Icons.landscape,
    'title': '自然・景色',
    'subtitle': '美しい自然の風景を探索',
  },
  {
    'icon': Icons.location_city,
    'title': '都市・街並み',
    'subtitle': '世界の魅力的な都市を発見',
  },
  {
    'icon': Icons.museum,
    'title': '文化・歴史',
    'subtitle': '歴史的な場所と文化遺産',
  },
  {
    'icon': Icons.restaurant,
    'title': 'グルメ・料理',
    'subtitle': '各地の美味しい料理を体験',
  },
  {
    'icon': Icons.sports_soccer,
    'title': 'アクティビティ',
    'subtitle': '楽しい体験と冒険',
  },
  {
    'icon': Icons.beach_access,
    'title': 'リゾート・海',
    'subtitle': 'リラックスできるビーチリゾート',
  },
];