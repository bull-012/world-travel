import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/features/profile/models/achievement.dart';
import 'package:world_travel/features/profile/providers/achievement_provider.dart';

class ProfilePageArgs {
  const ProfilePageArgs({
    required this.title,
  });

  final String title;
}

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({
    required this.args,
    super.key,
  });

  final ProfilePageArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final achievements = ref.watch(achievementNotifierProvider);
    final latestAchievement = ref.watch(achievementNotifierProvider.notifier).latestAchievement;
    
    return CustomScrollView(
      slivers: [
        // プロフィールヘッダー
        SliverAppBar(
          expandedHeight: 280,
          floating: false,
          pinned: true,
          backgroundColor: theme.colorScheme.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // 背景パターン
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/world_map_pattern.png'),
                            fit: BoxFit.cover,
                            opacity: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // プロフィール情報
                  Positioned(
                    bottom: 40,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // アバター
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: theme.colorScheme.surface,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                            .animate()
                            .scale(delay: const Duration(milliseconds: 300))
                            .fadeIn(duration: const Duration(milliseconds: 600)),
                        const SizedBox(height: 16),
                        // 名前
                        Text(
                          'Travel Explorer',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate(delay: const Duration(milliseconds: 500))
                            .slideX(begin: -0.3, duration: const Duration(milliseconds: 600))
                            .fadeIn(),
                        const SizedBox(height: 4),
                        // ステータス（現在の称号）
                        Row(
                          children: [
                            if (latestAchievement != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: latestAchievement.color.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      latestAchievement.icon,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      latestAchievement.title,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              '12ヶ国訪問済み',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        )
                            .animate(delay: const Duration(milliseconds: 700))
                            .slideX(begin: -0.3, duration: const Duration(milliseconds: 600))
                            .fadeIn(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // 統計情報
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '旅行統計',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.public,
                        title: '訪問国数',
                        value: '12',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.location_city,
                        title: '訪問都市',
                        value: '28',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.flight_takeoff,
                        title: '総移動距離',
                        value: '15.2K km',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.emoji_events,
                        title: '獲得称号',
                        value: '${ref.watch(achievementNotifierProvider.notifier).totalUnlockedCount}',
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate(delay: const Duration(milliseconds: 900))
              .slideY(begin: 0.3, duration: const Duration(milliseconds: 800))
              .fadeIn(),
        ),
        
        // 最近の旅行
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '最近の旅行',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final trips = [
                        {'city': '東京', 'country': '日本', 'date': '2024年3月', 'image': '🗼'},
                        {'city': 'パリ', 'country': 'フランス', 'date': '2024年1月', 'image': '🗼'},
                        {'city': 'ニューヨーク', 'country': 'アメリカ', 'date': '2023年11月', 'image': '🗽'},
                      ];
                      final trip = trips[index];
                      
                      return Container(
                        width: 160,
                        margin: EdgeInsets.only(
                          right: index < 2 ? 12 : 0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      theme.colorScheme.primaryContainer,
                                      theme.colorScheme.primary,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    trip['image']!,
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        trip['city']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${trip['country']} • ${trip['date']}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate(delay: Duration(milliseconds: 1100 + (index * 200)))
                          .slideX(begin: 0.3, duration: const Duration(milliseconds: 600))
                          .fadeIn();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 称号セクション
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '称号・実績',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => _AchievementsDialog(),
                        );
                      },
                      child: const Text('すべて見る'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final unlockedAchievements = ref
                          .watch(achievementNotifierProvider.notifier)
                          .unlockedAchievements
                          .take(5)
                          .toList();
                      
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: unlockedAchievements.length,
                        itemBuilder: (context, index) {
                          final achievement = unlockedAchievements[index];
                          
                          return Container(
                            width: 100,
                            margin: EdgeInsets.only(
                              right: index < unlockedAchievements.length - 1 ? 12 : 0,
                            ),
                            child: _AchievementCard(
                              achievement: achievement,
                              isCompact: true,
                            ),
                          )
                              .animate(delay: Duration(milliseconds: 1500 + (index * 100)))
                              .scale(duration: const Duration(milliseconds: 400))
                              .fadeIn();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        
        // アクションボタン
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ActionButton(
                  icon: Icons.edit,
                  title: 'プロフィールを編集',
                  subtitle: '名前、写真、自己紹介を変更',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('プロフィール編集機能（未実装）')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.settings,
                  title: '設定',
                  subtitle: '通知、プライバシー、アカウント設定',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('設定画面（未実装）')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.share,
                  title: '友達に紹介',
                  subtitle: 'アプリを友達にシェア',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('シェア機能（未実装）')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.help_outline,
                  title: 'ヘルプ・サポート',
                  subtitle: 'よくある質問、お問い合わせ',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ヘルプ画面（未実装）')),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          )
              .animate(delay: const Duration(milliseconds: 1800))
              .slideY(begin: 0.3, duration: const Duration(milliseconds: 800))
              .fadeIn(),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
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

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.achievement,
    this.isCompact = false,
  });

  final Achievement achievement;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(isCompact ? 8 : 12),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? achievement.color.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked
              ? achievement.color.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            achievement.icon,
            size: isCompact ? 24 : 32,
            color: achievement.isUnlocked
                ? achievement.color
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: (isCompact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
              fontWeight: FontWeight.w600,
              color: achievement.isUnlocked
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isCompact) ...[
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (!achievement.isUnlocked && achievement.maxProgress > 1) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: achievement.progressPercentage,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(achievement.color),
              minHeight: 4,
            ),
            const SizedBox(height: 4),
            Text(
              '${achievement.progress}/${achievement.maxProgress}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AchievementsDialog extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final achievements = ref.watch(achievementNotifierProvider);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '称号・実績',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return _AchievementCard(
                    achievement: achievement,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}