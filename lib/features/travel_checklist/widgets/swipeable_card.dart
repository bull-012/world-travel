import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:world_travel/features/travel_checklist/models/checklist_item.dart';

/// スワイプ可能なチェックリストカード
class SwipeableChecklistCard extends StatefulWidget {
  const SwipeableChecklistCard({
    required this.item,
    required this.onSwipeComplete,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onEditTap,
    super.key,
    this.cardIndex = 0,
    this.totalCards = 0,
    this.isInteractable = true,
    this.currentIndex = 0,
  });

  final ChecklistItem item;
  final VoidCallback onSwipeComplete;
  final bool Function() onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onEditTap;
  final int cardIndex;
  final int totalCards;
  final bool isInteractable;
  final int currentIndex;

  @override
  State<SwipeableChecklistCard> createState() => _SwipeableChecklistCardState();
}

class _SwipeableChecklistCardState extends State<SwipeableChecklistCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onSwipeComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isInteractable) return;
    setState(() {
      _isDragging = true;
      _dragOffset += details.delta;
    });
  }

  void _resetCard() {
    setState(() {
      _isDragging = false;
      _dragOffset = Offset.zero;
    });
    _controller.reset();

    // アニメーションも初期状態にリセット
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(_controller);

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1,
    ).animate(_controller);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isInteractable) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final dragDistance = _dragOffset.dx.abs();
    final threshold = screenWidth * 0.3;

    if (dragDistance >= threshold) {
      // スワイプアニメーション
      final targetX = _dragOffset.dx > 0 ? screenWidth : -screenWidth;
      final targetRotation = _dragOffset.dx > 0 ? 0.3 : -0.3;

      _animation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset(targetX, _dragOffset.dy),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );

      _rotationAnimation = Tween<double>(
        begin: _dragOffset.dx / screenWidth * 0.3,
        end: targetRotation,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );

      _controller.forward(from: 0).then((_) {
        if (_dragOffset.dx > 0) {
          widget.onSwipeRight();
          widget.onSwipeComplete();
        } else {
          // 左スワイプの場合、戻り値で処理が成功したかチェック
          final handled = widget.onSwipeLeft();
          if (handled) {
            widget.onSwipeComplete();
          }
        }

        // 短い遅延後にカードをリセット
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _resetCard();
          }
        });
      });
    } else {
      // 元の位置に戻る
      setState(() {
        _isDragging = false;
        _dragOffset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;
    final screenHeight = MediaQuery.of(context).size.height;
    const swipeHintHeight = 70 + 40; // スワイプヒントの高さ + bottom位置
    final availableHeight = screenHeight -
        100 -
        36 -
        swipeHintHeight -
        24; // AppBar + padding + スワイプヒント + 24px間隔
    final cardHeight = availableHeight;

    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = _isDragging ? _dragOffset : _animation.value;
            final rotation = _isDragging
                ? _dragOffset.dx / screenWidth * 0.3
                : _rotationAnimation.value;
            final scale = _isDragging ? 1.0 : _scaleAnimation.value;

            return Transform.translate(
              offset: offset,
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 背景グラデーション
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.05),
                                  theme.colorScheme.secondary
                                      .withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // メインコンテンツ
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // プログレスインジケーター
                                if (widget.totalCards > 0) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${widget.cardIndex + 1} / ${widget.totalCards}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: (widget.cardIndex + 1) /
                                        widget.totalCards,
                                    backgroundColor: theme
                                        .colorScheme.surfaceContainerHighest,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // カテゴリーバッジ
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.item.category,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // アイコン
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.item.icon,
                                    size: 35,
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                                    .animate(
                                      onPlay: (controller) =>
                                          controller.repeat(reverse: true),
                                    )
                                    .scale(
                                      begin: const Offset(1, 1),
                                      end: const Offset(1.1, 1.1),
                                      duration:
                                          const Duration(milliseconds: 1500),
                                      curve: Curves.easeInOut,
                                    ),
                                const SizedBox(height: 16),

                                // 質問テキスト
                                Text(
                                  widget.item.question,
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (widget.item.description != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.item.description!,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],

                                const Spacer(),

                                const SizedBox(height: 20),

                                // 編集ボタン
                                if (widget.isInteractable)
                                  SizedBox(
                                    height: 44,
                                    child: FilledButton.tonal(
                                      onPressed: widget.onEditTap,
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size.fromHeight(44),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.edit_note),
                                          SizedBox(width: 8),
                                          Text('もう一度準備する'),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // スワイプインジケーター
                        if (_isDragging && widget.isInteractable)
                          Positioned(
                            bottom: 16,
                            right: 40,
                            child: AnimatedOpacity(
                              opacity: _dragOffset.dx > 50 ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        if (_isDragging &&
                            widget.isInteractable &&
                            widget.currentIndex > 0)
                          Positioned(
                            bottom: 16,
                            left: 40,
                            child: AnimatedOpacity(
                              opacity: _dragOffset.dx < -50 ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
