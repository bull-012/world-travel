import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/features/travel_checklist/models/checklist_item.dart';
import 'package:world_travel/features/travel_checklist/providers/checklist_provider.dart';
import 'package:world_travel/features/travel_checklist/widgets/swipeable_card.dart';

/// 旅行準備チェックリストページ
class TravelChecklistPage extends ConsumerStatefulWidget {
  const TravelChecklistPage({super.key});

  @override
  ConsumerState<TravelChecklistPage> createState() =>
      _TravelChecklistPageState();
}

class _TravelChecklistPageState extends ConsumerState<TravelChecklistPage>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  int _currentIndex = 0;
  List<ChecklistItem> _pendingItems = [];

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _initializePendingItems();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _initializePendingItems() {
    final checklist = ref.read(checklistNotifierProvider);
    _pendingItems = checklist.where((item) => !item.isCompleted).toList();
  }

  void _handleSwipeComplete() {
    setState(() {
      if (_currentIndex < _pendingItems.length - 1) {
        _currentIndex++;
      } else {
        // すべてのカードをスワイプ完了
        _showCompletionDialog();
      }
    });
  }

  void _handleSwipeLeft() {
    // まだ準備が必要
    final item = _pendingItems[_currentIndex];
    ref
        .read(checklistNotifierProvider.notifier)
        .updateItemStatus(item.id, isCompleted: false);
  }

  void _handleSwipeRight() {
    // 準備完了
    final item = _pendingItems[_currentIndex];
    ref
        .read(checklistNotifierProvider.notifier)
        .updateItemStatus(item.id, isCompleted: true);
  }

  void _handlePrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _handleNext() {
    _handleSwipeComplete();
  }

  void _showCompletionDialog() {
    final notifier = ref.read(checklistNotifierProvider.notifier);
    final progress = notifier.progress;

    if (progress == 1.0) {
      // 全て完了
      _confettiController.forward();
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                progress == 1.0 ? Icons.celebration : Icons.check_circle,
                size: 80,
                color: progress == 1.0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                progress == 1.0 ? '準備完了！' : 'チェック完了',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                progress == 1.0
                    ? 'すべての準備が整いました！\n素敵な旅行を楽しんでください。'
                    : '${notifier.completedCount}/${notifier.totalCount}個の項目を確認しました。',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.pop();
                    },
                    child: const Text('閉じる'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _currentIndex = 0;
                        _initializePendingItems();
                      });
                    },
                    child: const Text('もう一度確認'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = ref.watch(checklistNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('旅行準備チェックリスト'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              // リスト表示画面へ遷移
              context.push('/travel-checklist/list');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 背景
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest,
                ],
              ),
            ),
          ),

          if (_pendingItems.isEmpty) ...[
            // すべて完了している場合
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 120,
                    color: theme.colorScheme.primary,
                  )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.1, 1.1),
                        duration: const Duration(milliseconds: 1500),
                      ),
                  const SizedBox(height: 24),
                  Text(
                    'すべての準備が完了しています！',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '素敵な旅行をお楽しみください',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      notifier.resetAll();
                      setState(() {
                        _currentIndex = 0;
                        _initializePendingItems();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('リセット'),
                  ),
                ],
              ),
            ),
          ] else ...[
            // カードスタック
            if (_currentIndex < _pendingItems.length)
              Stack(
                children: [
                  // 背景のカード（次のカード）
                  if (_currentIndex < _pendingItems.length - 1)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 66), // 36 + 30
                        child: Transform.scale(
                          scale: 0.9,
                          child: Opacity(
                            opacity: 0.7,
                            child: SwipeableChecklistCard(
                              item: _pendingItems[_currentIndex + 1],
                              onSwipeComplete: () {},
                              onSwipeLeft: () {},
                              onSwipeRight: () {},
                              onEditTap: () {},
                              cardIndex: _currentIndex + 1,
                              totalCards: _pendingItems.length,
                              isInteractable: false,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // メインカード
                  Padding(
                    padding: const EdgeInsets.only(top: 36),
                    child: SwipeableChecklistCard(
                      key: ValueKey(_pendingItems[_currentIndex].id),
                      item: _pendingItems[_currentIndex],
                      onSwipeComplete: _handleSwipeComplete,
                      onSwipeLeft: _handleSwipeLeft,
                      onSwipeRight: _handleSwipeRight,
                      onEditTap: () {
                        // 詳細編集画面へ遷移
                        context.push(
                          '/travel-checklist/detail',
                          extra: _pendingItems[_currentIndex],
                        );
                      },
                      cardIndex: _currentIndex,
                      totalCards: _pendingItems.length,
                    ),
                  ),
                ],
              ),
          ],

          // 下部固定のスワイプヒント
          if (_currentIndex < _pendingItems.length)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 戻るボタン（最初のカードでは非表示）
                    if (_currentIndex > 0)
                      _SwipeHint(
                        icon: Icons.arrow_back,
                        label: '戻る',
                        color: Colors.orange,
                        isLeft: true,
                        onTap: _handlePrevious,
                      )
                    else
                      const SizedBox(width: 50), // スペースを保持

                    // 次へボタン
                    _SwipeHint(
                      icon: Icons.arrow_forward,
                      label: '次へ',
                      color: Colors.blue,
                      isLeft: false,
                      onTap: _handleNext,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// スワイプヒントウィジェット
class _SwipeHint extends StatelessWidget {
  const _SwipeHint({
    required this.icon,
    required this.label,
    required this.color,
    required this.isLeft,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isLeft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
