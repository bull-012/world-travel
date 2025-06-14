import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 統計情報を表示するためのカードコンポーネント
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
    this.animationDelay,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // アイコン
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              
              // 値
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              
              // タイトル
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              // サブタイトル
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // アニメーション適用
    if (animationDelay != null) {
      card = card
          .animate(delay: animationDelay!)
          .fadeIn(duration: const Duration(milliseconds: 600))
          .slideY(begin: 0.2)
          .scale(
            begin: const Offset(0.8, 0.8),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
    }

    return card;
  }
}

/// 横向きレイアウトの統計カード
class HorizontalStatCard extends StatelessWidget {
  const HorizontalStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trend,
    this.onTap,
    this.animationDelay,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final StatTrend? trend;
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
                    Row(
                      children: [
                        Text(
                          value,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        if (trend != null) ...[
                          const SizedBox(width: 4),
                          Icon(
                            trend!.isPositive
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 16,
                            color: trend!.isPositive ? Colors.green : Colors.red,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // アニメーション適用
    if (animationDelay != null) {
      card = card
          .animate(delay: animationDelay!)
          .fadeIn(duration: const Duration(milliseconds: 400))
          .slideX(begin: 0.3);
    }

    return card;
  }
}

/// 統計のトレンド情報
class StatTrend {
  const StatTrend({
    required this.isPositive,
    this.percentage,
  });

  final bool isPositive;
  final double? percentage;
}