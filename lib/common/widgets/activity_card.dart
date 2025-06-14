import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 活動履歴を表示するためのカードコンポーネント
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.time,
    this.onTap,
    this.animationDelay,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String time;
  final VoidCallback? onTap;
  final Duration? animationDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
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
        title: Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );

    // アニメーション適用
    if (animationDelay != null) {
      card = card
          .animate(delay: animationDelay!)
          .fadeIn(duration: const Duration(milliseconds: 400))
          .slideX(
            begin: 0.3,
            duration: const Duration(milliseconds: 600),
          );
    }

    return card;
  }
}

/// タイムライン形式の活動カード
class TimelineActivityCard extends StatelessWidget {
  const TimelineActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.time,
    this.isLast = false,
    this.onTap,
    this.animationDelay,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String time;
  final bool isLast;
  final VoidCallback? onTap;
  final Duration? animationDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイムライン
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.only(top: 8),
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // コンテンツ
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            time,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // アニメーション適用
    if (animationDelay != null) {
      card = card
          .animate(delay: animationDelay!)
          .fadeIn(duration: const Duration(milliseconds: 600))
          .slideX(
            begin: 0.3,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
          );
    }

    return card;
  }
}

/// コンパクトな活動通知カード
class CompactActivityCard extends StatelessWidget {
  const CompactActivityCard({
    super.key,
    required this.title,
    required this.time,
    this.icon,
    this.color,
    this.onTap,
    this.onDismiss,
    this.animationDelay,
  });

  final String title;
  final String time;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration? animationDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;
    
    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: icon != null
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: cardColor,
                  size: 16,
                ),
              )
            : null,
        title: Text(
          title,
          style: theme.textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // アニメーション適用
    if (animationDelay != null) {
      card = card
          .animate(delay: animationDelay!)
          .fadeIn(duration: const Duration(milliseconds: 300))
          .slideY(begin: -0.2);
    }

    return card;
  }
}