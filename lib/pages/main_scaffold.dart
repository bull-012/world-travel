import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/pages/home_page.dart';
import 'package:world_travel/pages/explore_page.dart';
import 'package:world_travel/pages/destinations_page.dart';
import 'package:world_travel/features/profile/pages/sample_page.dart';

class MainScaffold extends HookConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MainScaffoldView();
  }
}

class MainScaffoldView extends StatefulWidget {
  const MainScaffoldView({super.key});

  @override
  State<MainScaffoldView> createState() => _MainScaffoldViewState();
}

class _MainScaffoldViewState extends State<MainScaffoldView>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // FABアニメーション
      _fabAnimationController.forward().then((_) {
        _fabAnimationController.reverse();
      });
    }
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // アイコンとインジケーター
              Stack(
                alignment: Alignment.center,
                children: [
                  // 背景インジケーター
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 40 : 0,
                    height: isSelected ? 40 : 0,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  // アイコン
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      isSelected ? filledIcon : outlinedIcon,
                      key: ValueKey(
                        '${isSelected ? 'filled' : 'outlined'}_$index',
                      ),
                      color: isSelected 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // ラベル
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  height: 1,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ).animate(
        target: isSelected ? 1 : 0,
      ).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      ),
    );
  }

  Widget _buildFAB() {
    switch (_selectedIndex) {
      case 0: // Home
        return FloatingActionButton.extended(
          onPressed: () {
            // 新しい旅行プラン作成
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('新しい旅行プランを作成')),
            );
          },
          icon: const Icon(Icons.add_location_outlined),
          label: const Text('新しい旅行'),
          heroTag: 'homeFab',
        );
      case 1: // Explore
        return FloatingActionButton(
          onPressed: () {
            // 検索機能
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('検索機能')),
            );
          },
          child: const Icon(Icons.search),
          heroTag: 'exploreFab',
        );
      case 2: // Destinations
        return FloatingActionButton(
          onPressed: () {
            // お気に入り追加
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('お気に入りに追加')),
            );
          },
          child: const Icon(Icons.favorite_border),
          heroTag: 'destinationsFab',
        );
      case 3: // Profile
        return FloatingActionButton(
          onPressed: () {
            // 設定画面
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('設定画面')),
            );
          },
          child: const Icon(Icons.settings_outlined),
          heroTag: 'profileFab',
        );
      default:
        return FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
          heroTag: 'defaultFab',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          HomePage(),
          ExplorePage(),
          DestinationsPage(),
          SamplePage(args: SamplePageArgs(title: 'プロフィール')),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
                ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  0,
                  Icons.home_outlined,
                  Icons.home,
                  'ホーム',
                ),
                _buildNavItem(
                  context,
                  1,
                  Icons.explore_outlined,
                  Icons.explore,
                  '探索',
                ),
                _buildNavItem(
                  context,
                  2,
                  Icons.place_outlined,
                  Icons.place,
                  '目的地',
                ),
                _buildNavItem(
                  context,
                  3,
                  Icons.person_outline,
                  Icons.person,
                  'プロフィール',
                ),
              ],
            ),
          ),
        ),
      ).animate().slideY(
        begin: 1,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        delay: const Duration(milliseconds: 400),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_fabAnimationController.value * 0.1),
            child: _buildFAB(),
          );
        },
      ).animate().scale(
        begin: Offset.zero,
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        delay: const Duration(milliseconds: 800),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}