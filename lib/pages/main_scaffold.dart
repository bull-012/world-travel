import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/features/profile/pages/profile_page.dart';
import 'package:world_travel/pages/destinations_page.dart';
import 'package:world_travel/pages/explore_page.dart';
import 'package:world_travel/pages/home_page.dart';

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
          heroTag: 'exploreFab',
          child: const Icon(Icons.search),
        );
      case 2: // Destinations
        return FloatingActionButton(
          onPressed: () {
            // お気に入り追加
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('お気に入りに追加')),
            );
          },
          heroTag: 'destinationsFab',
          child: const Icon(Icons.favorite_border),
        );
      case 3: // Profile
        return FloatingActionButton(
          onPressed: () {
            // プロフィール編集
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('プロフィール編集')),
            );
          },
          heroTag: 'profileFab',
          child: const Icon(Icons.edit),
        );
      default:
        return FloatingActionButton(
          onPressed: () {},
          heroTag: 'defaultFab',
          child: const Icon(Icons.add),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          ProfilePage(args: ProfilePageArgs(title: 'プロフィール')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: '探索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_outlined),
            activeIcon: Icon(Icons.edit_calendar),
            label: '旅の計画',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
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
