import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:world_travel/common/widgets/index.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedCategory = 'すべて';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: '場所、アクティビティを検索...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text('探索'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'おすすめ'),
            Tab(text: '人気'),
            Tab(text: '新着'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // おすすめタブ
          _buildRecommendedTab(),
          // 人気タブ
          _buildPopularTab(),
          // 新着タブ
          _buildNewTab(),
        ],
      ),
    );
  }

  Widget _buildRecommendedTab() {
    final searchQuery = _searchController.text.toLowerCase();
    final filteredDestinations = _recommendedDestinations.where((dest) {
      if (searchQuery.isEmpty) return true;
      return dest['title'].toString().toLowerCase().contains(searchQuery) ||
          dest['location'].toString().toLowerCase().contains(searchQuery) ||
          dest['description'].toString().toLowerCase().contains(searchQuery);
    }).toList();

    return CustomScrollView(
      slivers: [
        // カテゴリセクション
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'カテゴリから探す',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category['title'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _CategoryCard(
                        icon: category['icon'] as IconData,
                        title: category['title'] as String,
                        subtitle: category['subtitle'] as String,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategory = isSelected ? 'すべて' : category['title'] as String;
                          });
                        },
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // おすすめセクション
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'あなたへのおすすめ',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('すべて表示'),
                ),
              ],
            ),
          ),
        ),

        // おすすめリスト
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (filteredDestinations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '検索結果が見つかりませんでした',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final destination = filteredDestinations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TravelCard(
                    title: destination['title'] as String,
                    subtitle: destination['location'] as String,
                    icon: Icons.place,
                    rating: destination['rating'] as double,
                    price: destination['price'] as String,
                    animationDelay: Duration(milliseconds: index * 100),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${destination['title']}の詳細')),
                      );
                    },
                  ),
                );
              },
              childCount: filteredDestinations.isEmpty ? 1 : filteredDestinations.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _popularDestinations.length,
      itemBuilder: (context, index) {
        final destination = _popularDestinations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _PopularCard(
            rank: index + 1,
            title: destination['title'] as String,
            location: destination['location'] as String,
            imageUrl: destination['imageUrl'] as String,
            visitors: destination['visitors'] as String,
            trend: destination['trend'] as double,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${destination['title']}の詳細')),
              );
            },
          ).animate(delay: Duration(milliseconds: index * 100))
            .fadeIn(duration: 600.ms)
            .slideX(begin: 0.2),
        );
      },
    );
  }

  Widget _buildNewTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _newDestinations.length,
      itemBuilder: (context, index) {
        final destination = _newDestinations[index];
        return _NewDestinationCard(
          title: destination['title'] as String,
          location: destination['location'] as String,
          imageUrl: destination['imageUrl'] as String,
          date: destination['date'] as String,
          category: destination['category'] as String,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${destination['title']}の詳細')),
            );
          },
        ).animate(delay: Duration(milliseconds: index * 50))
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'フィルター',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () {
                      // リセット処理
                      Navigator.pop(context);
                    },
                    child: const Text('リセット'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _FilterSection(
                    title: '価格帯',
                    child: Wrap(
                      spacing: 8,
                      children: ['低価格', '中価格', '高価格', 'プレミアム'].map((price) {
                        return FilterChip(
                          label: Text(price),
                          selected: false,
                          onSelected: (selected) {},
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: '評価',
                    child: Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: index < 4 ? Colors.amber : Colors.grey.shade300,
                          ),
                          onPressed: () {},
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: '距離',
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0 km'),
                            Text('1000 km'),
                          ],
                        ),
                        Slider(
                          value: 500,
                          min: 0,
                          max: 1000,
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('フィルターを適用しました')),
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('適用する'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// UI Components
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? theme.colorScheme.primaryContainer 
            : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({
    required this.rank,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.visitors,
    required this.trend,
    required this.onTap,
  });

  final int rank;
  final String title;
  final String location;
  final String imageUrl;
  final String visitors;
  final double trend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTop3 = rank <= 3;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ランク表示
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isTop3 ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: isTop3 ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 画像
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              // 情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            visitors,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          trend > 0 ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: trend > 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trend.abs()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: trend > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 矢印
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewDestinationCard extends StatelessWidget {
  const _NewDestinationCard({
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.date,
    required this.category,
    required this.onTap,
  });

  final String title;
  final String location;
  final String imageUrl;
  final String date;
  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 画像部分
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.image, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'NEW',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 情報部分
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          date,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
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
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

// データ
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

final List<Map<String, dynamic>> _recommendedDestinations = [
  {
    'title': '富士山',
    'location': '静岡県・山梨県',
    'description': '日本の象徴的な山',
    'imageUrl': 'assets/images/fuji.jpg',
    'rating': 4.8,
    'price': '￥5,000〜',
  },
  {
    'title': 'バリ島',
    'location': 'インドネシア',
    'description': '神々の島',
    'imageUrl': 'assets/images/bali.jpg',
    'rating': 4.7,
    'price': '￥30,000〜',
  },
  {
    'title': 'パリ',
    'location': 'フランス',
    'description': '芸術とファッションの都',
    'imageUrl': 'assets/images/paris.jpg',
    'rating': 4.9,
    'price': '￥80,000〜',
  },
];

final List<Map<String, dynamic>> _popularDestinations = [
  {
    'title': '東京スカイツリー',
    'location': '東京都墨田区',
    'imageUrl': 'assets/images/skytree.jpg',
    'visitors': '月間50万人',
    'trend': 15.2,
  },
  {
    'title': '清水寺',
    'location': '京都府京都市',
    'imageUrl': 'assets/images/kiyomizu.jpg',
    'visitors': '月間30万人',
    'trend': 8.5,
  },
  {
    'title': 'ユニバーサル・スタジオ・ジャパン',
    'location': '大阪府大阪市',
    'imageUrl': 'assets/images/usj.jpg',
    'visitors': '月間100万人',
    'trend': -3.2,
  },
  {
    'title': '金閣寺',
    'location': '京都府京都市',
    'imageUrl': 'assets/images/kinkaku.jpg',
    'visitors': '月間25万人',
    'trend': 12.0,
  },
  {
    'title': '浅草寺',
    'location': '東京都台東区',
    'imageUrl': 'assets/images/sensoji.jpg',
    'visitors': '月間40万人',
    'trend': 5.8,
  },
];

final List<Map<String, dynamic>> _newDestinations = [
  {
    'title': 'チームラボボーダレス',
    'location': '東京都江東区',
    'imageUrl': 'assets/images/teamlab.jpg',
    'date': '2日前',
    'category': 'アート',
  },
  {
    'title': '白川郷',
    'location': '岐阜県',
    'imageUrl': 'assets/images/shirakawa.jpg',
    'date': '3日前',
    'category': '文化',
  },
  {
    'title': '竹富島',
    'location': '沖縄県',
    'imageUrl': 'assets/images/taketomi.jpg',
    'date': '5日前',
    'category': 'リゾート',
  },
  {
    'title': '六本木ヒルズ展望台',
    'location': '東京都港区',
    'imageUrl': 'assets/images/roppongi.jpg',
    'date': '1週間前',
    'category': '都市',
  },
  {
    'title': '嵐山',
    'location': '京都府京都市',
    'imageUrl': 'assets/images/arashiyama.jpg',
    'date': '1週間前',
    'category': '自然',
  },
  {
    'title': '道頓堀',
    'location': '大阪府大阪市',
    'imageUrl': 'assets/images/dotonbori.jpg',
    'date': '2週間前',
    'category': 'グルメ',
  },
];