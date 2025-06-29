import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/features/travel_checklist/models/checklist_item.dart';
import 'package:world_travel/features/travel_checklist/providers/checklist_provider.dart';

/// チェックリスト項目の詳細編集ページ
class ChecklistDetailPage extends ConsumerStatefulWidget {
  const ChecklistDetailPage({
    required this.item,
    super.key,
  });

  final ChecklistItem item;

  @override
  ConsumerState<ChecklistDetailPage> createState() =>
      _ChecklistDetailPageState();
}

class _ChecklistDetailPageState extends ConsumerState<ChecklistDetailPage> {
  final _notesController = TextEditingController();
  final List<bool> _tipChecks = [];

  @override
  void initState() {
    super.initState();
    // チップのチェック状態を初期化
    _tipChecks.addAll(List.filled(widget.item.tips.length, false));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checklist = ref.watch(checklistNotifierProvider);
    final currentItem = checklist.firstWhere(
      (item) => item.id == widget.item.id,
      orElse: () => widget.item,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('準備の詳細'),
        actions: [
          IconButton(
            icon: Icon(
              currentItem.isCompleted
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: currentItem.isCompleted ? Colors.green : null,
            ),
            onPressed: () {
              ref.read(checklistNotifierProvider.notifier).updateItemStatus(
                    widget.item.id,
                    isCompleted: !currentItem.isCompleted,
                  );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダーセクション
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // アイコン
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.item.icon,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ).animate().scale(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(height: 16),

                  // カテゴリーバッジ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.item.category,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 質問
                  Text(
                    widget.item.question,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.item.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.item.description!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            // ステータスカード
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        currentItem.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: currentItem.isCompleted
                            ? Colors.green
                            : theme.colorScheme.outline,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ステータス',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              currentItem.isCompleted ? '準備完了' : '準備中',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: currentItem.isCompleted
                                    ? Colors.green
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: currentItem.isCompleted,
                        onChanged: (value) {
                          ref
                              .read(checklistNotifierProvider.notifier)
                              .updateItemStatus(
                                widget.item.id,
                                isCompleted: value,
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
            ),

            // チェックポイント
            if (widget.item.tips.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'チェックポイント',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...widget.item.tips.asMap().entries.map((entry) {
                final index = entry.key;
                final tip = entry.value;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Card(
                    child: CheckboxListTile(
                      value: _tipChecks[index],
                      onChanged: (value) {
                        setState(() {
                          _tipChecks[index] = value ?? false;
                        });
                      },
                      title: Text(tip),
                      controlAffinity: ListTileControlAffinity.leading,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
                    .animate(delay: Duration(milliseconds: 100 * index))
                    .fadeIn(duration: const Duration(milliseconds: 400))
                    .slideX(begin: 0.1);
              }),
              const SizedBox(height: 16),
            ],

            // メモセクション
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'メモ',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _notesController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '準備に関するメモを記入...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // アクションボタン
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('戻る'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        // すべてのチェックポイントが完了していれば準備完了にする
                        final allChecked = _tipChecks.every((check) => check);
                        if (allChecked && !currentItem.isCompleted) {
                          ref
                              .read(checklistNotifierProvider.notifier)
                              .updateItemStatus(
                                widget.item.id,
                                isCompleted: true,
                              );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('準備が完了しました！'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }

                        context.pop();
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
