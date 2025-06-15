import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreateTravelPlanPage extends HookConsumerWidget {
  const CreateTravelPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pageController = usePageController();
    final currentStep = useState(0);
    
    // フォームの状態管理
    final titleController = useTextEditingController();
    final destinationController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final budgetController = useTextEditingController();
    final selectedCategory = useState<String?>(null);
    final selectedDuration = useState<String?>(null);
    final startDate = useState<DateTime?>(null);
    final endDate = useState<DateTime?>(null);
    final participants = useState(1);
    final selectedTemplate = useState<String?>(null);

    // ステップ管理
    final steps = [
      '基本情報',
      '日程・予算',
      '詳細設定',
      '確認',
    ];

    void nextStep() {
      if (currentStep.value < steps.length - 1) {
        currentStep.value++;
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    void previousStep() {
      if (currentStep.value > 0) {
        currentStep.value--;
        pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    void createPlan() {
      // 計画作成処理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('「${titleController.text}」の計画を作成しました！'),
          backgroundColor: theme.colorScheme.primary,
        ),
      );
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('新しい旅行計画'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ステッププログレス
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    final isActive = index <= currentStep.value;
                    final isCurrent = index == currentStep.value;
                    
                    return Expanded(
                      child: Row(
                        children: [
                          // ステップ番号
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? theme.colorScheme.primary 
                                  : theme.colorScheme.outline.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isActive
                                  ? Icon(
                                      isCurrent ? Icons.edit : Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: theme.colorScheme.outline,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          // 連結線（最後以外）
                          if (index < steps.length - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                color: isActive 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    
                    return Expanded(
                      child: Text(
                        step,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: index <= currentStep.value 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.outline,
                          fontWeight: index == currentStep.value 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideY(begin: -0.2),

          // ページビュー
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // ステップ1: 基本情報
                _buildBasicInfoStep(
                  context,
                  theme,
                  titleController,
                  destinationController,
                  selectedCategory,
                  selectedTemplate,
                ),
                
                // ステップ2: 日程・予算
                _buildScheduleBudgetStep(
                  context,
                  theme,
                  selectedDuration,
                  startDate,
                  endDate,
                  budgetController,
                  participants,
                ),
                
                // ステップ3: 詳細設定
                _buildDetailStep(
                  context,
                  theme,
                  descriptionController,
                ),
                
                // ステップ4: 確認
                _buildConfirmStep(
                  context,
                  theme,
                  titleController,
                  destinationController,
                  selectedCategory,
                  selectedDuration,
                  startDate,
                  endDate,
                  budgetController,
                  participants,
                  descriptionController,
                ),
              ],
            ),
          ),

          // ナビゲーションボタン
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (currentStep.value > 0)
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: previousStep,
                      child: const Text('戻る'),
                    ),
                  ),
                if (currentStep.value > 0) const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: currentStep.value == steps.length - 1 
                        ? createPlan 
                        : nextStep,
                    child: Text(
                      currentStep.value == steps.length - 1 
                          ? '計画を作成' 
                          : '次へ',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ステップ1: 基本情報
Widget _buildBasicInfoStep(
  BuildContext context,
  ThemeData theme,
  TextEditingController titleController,
  TextEditingController destinationController,
  ValueNotifier<String?> selectedCategory,
  ValueNotifier<String?> selectedTemplate,
) {
  final categories = [
    {'name': '文化・歴史', 'icon': Icons.temple_buddhist, 'color': Colors.brown},
    {'name': 'アート・文化', 'icon': Icons.museum, 'color': Colors.purple},
    {'name': 'リゾート・ビーチ', 'icon': Icons.beach_access, 'color': Colors.blue},
    {'name': '自然・アドベンチャー', 'icon': Icons.landscape, 'color': Colors.green},
    {'name': 'グルメ・料理', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'ショッピング', 'icon': Icons.shopping_bag, 'color': Colors.pink},
  ];

  final templates = [
    {'name': '週末旅行', 'description': '2-3日の短期旅行', 'icon': Icons.weekend},
    {'name': 'リゾート旅行', 'description': '5-7日のリラックス旅行', 'icon': Icons.beach_access},
    {'name': '文化探訪', 'description': '歴史と文化を学ぶ旅', 'icon': Icons.temple_buddhist},
    {'name': '冒険旅行', 'description': 'アウトドア活動中心の旅', 'icon': Icons.hiking},
  ];

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '基本情報を入力してください',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 200))
            .slideX(begin: -0.3),
        
        const SizedBox(height: 24),
        
        // テンプレート選択
        Text(
          'テンプレートから選択（オプション）',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            final isSelected = selectedTemplate.value == template['name'];
            
            return GestureDetector(
              onTap: () {
                selectedTemplate.value = isSelected ? null : template['name'] as String;
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primaryContainer 
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          template['icon'] as IconData,
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            template['name'] as String,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected 
                                  ? theme.colorScheme.primary 
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template['description'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
            .animate(delay: const Duration(milliseconds: 400))
            .fadeIn(duration: const Duration(milliseconds: 600)),
        
        const SizedBox(height: 24),
        
        // 旅行タイトル
        Text(
          '旅行タイトル',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: '例: 春の京都桜巡りツアー',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.title),
          ),
        )
            .animate(delay: const Duration(milliseconds: 600))
            .fadeIn(duration: const Duration(milliseconds: 600))
            .slideX(begin: 0.3),
        
        const SizedBox(height: 16),
        
        // 目的地
        Text(
          '目的地',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: destinationController,
          decoration: InputDecoration(
            hintText: '例: 京都, 日本',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.location_on),
          ),
        )
            .animate(delay: const Duration(milliseconds: 800))
            .fadeIn(duration: const Duration(milliseconds: 600))
            .slideX(begin: 0.3),
        
        const SizedBox(height: 24),
        
        // カテゴリー選択
        Text(
          'カテゴリー',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory.value == category['name'];
            
            return GestureDetector(
              onTap: () {
                selectedCategory.value = category['name'] as String;
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (category['color'] as Color).withValues(alpha: 0.1) 
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? category['color'] as Color 
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: isSelected 
                          ? category['color'] as Color 
                          : theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category['name'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? category['color'] as Color 
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
            .animate(delay: const Duration(milliseconds: 1000))
            .fadeIn(duration: const Duration(milliseconds: 600)),
      ],
    ),
  );
}

// ステップ2: 日程・予算
Widget _buildScheduleBudgetStep(
  BuildContext context,
  ThemeData theme,
  ValueNotifier<String?> selectedDuration,
  ValueNotifier<DateTime?> startDate,
  ValueNotifier<DateTime?> endDate,
  TextEditingController budgetController,
  ValueNotifier<int> participants,
) {
  final durations = ['1日', '2-3日', '4-5日', '1週間', '1-2週間', '1ヶ月以上'];

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '日程と予算を設定してください',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 200))
            .slideX(begin: -0.3),
        
        const SizedBox(height: 24),
        
        // 期間選択
        Text(
          '旅行期間',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: durations.map((duration) {
            final isSelected = selectedDuration.value == duration;
            return GestureDetector(
              onTap: () {
                selectedDuration.value = duration;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  duration,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        )
            .animate(delay: const Duration(milliseconds: 400))
            .fadeIn(duration: const Duration(milliseconds: 600)),
        
        const SizedBox(height: 24),
        
        // 日程選択
        Text(
          '出発・帰国日',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    startDate.value = date;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          startDate.value != null 
                              ? '${startDate.value!.month}/${startDate.value!.day}'
                              : '出発日',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate.value?.add(const Duration(days: 1)) ?? 
                        DateTime.now().add(const Duration(days: 1)),
                    firstDate: startDate.value ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    endDate.value = date;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          endDate.value != null 
                              ? '${endDate.value!.month}/${endDate.value!.day}'
                              : '帰国日',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
            .animate(delay: const Duration(milliseconds: 600))
            .fadeIn(duration: const Duration(milliseconds: 600))
            .slideY(begin: 0.3),
        
        const SizedBox(height: 24),
        
        // 予算
        Text(
          '予算',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '例: 100000',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.currency_yen),
            suffixText: '円',
          ),
        )
            .animate(delay: const Duration(milliseconds: 800))
            .fadeIn(duration: const Duration(milliseconds: 600))
            .slideX(begin: 0.3),
        
        const SizedBox(height: 24),
        
        // 参加者数
        Text(
          '参加者数',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.people),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${participants.value}名',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              IconButton(
                onPressed: participants.value > 1 
                    ? () => participants.value-- 
                    : null,
                icon: const Icon(Icons.remove),
              ),
              IconButton(
                onPressed: () => participants.value++,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        )
            .animate(delay: const Duration(milliseconds: 1000))
            .fadeIn(duration: const Duration(milliseconds: 600))
            .slideY(begin: 0.3),
      ],
    ),
  );
}

// ステップ3: 詳細設定
Widget _buildDetailStep(
  BuildContext context,
  ThemeData theme,
  TextEditingController descriptionController,
) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '詳細情報を追加してください',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 200))
            .slideX(begin: -0.3),
        
        const SizedBox(height: 24),
        
        // 旅行の説明
        Text(
          '旅行の説明',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '例: 古都京都の美しい桜を巡る3日間の旅。清水寺、金閣寺、嵐山を訪問予定。',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.description),
            ),
          ),
        )
            .animate(delay: const Duration(milliseconds: 400))
            .fadeIn(duration: const Duration(milliseconds: 600))
            .slideY(begin: 0.3),
        
        const SizedBox(height: 24),
        
        // 旅行のポイント
        Text(
          '旅行のポイント',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildPointCard(
              theme,
              Icons.camera_alt,
              '写真撮影',
              '美しい景色や思い出を記録',
              Colors.purple,
            ),
            const SizedBox(height: 8),
            _buildPointCard(
              theme,
              Icons.restaurant,
              'グルメ体験',
              '現地の美味しい料理を堪能',
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildPointCard(
              theme,
              Icons.temple_buddhist,
              '文化体験',
              '歴史や伝統文化に触れる',
              Colors.brown,
            ),
          ],
        )
            .animate(delay: const Duration(milliseconds: 600))
            .fadeIn(duration: const Duration(milliseconds: 600)),
      ],
    ),
  );
}

Widget _buildPointCard(
  ThemeData theme,
  IconData icon,
  String title,
  String description,
  Color color,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withValues(alpha: 0.3),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
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
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ステップ4: 確認
Widget _buildConfirmStep(
  BuildContext context,
  ThemeData theme,
  TextEditingController titleController,
  TextEditingController destinationController,
  ValueNotifier<String?> selectedCategory,
  ValueNotifier<String?> selectedDuration,
  ValueNotifier<DateTime?> startDate,
  ValueNotifier<DateTime?> endDate,
  TextEditingController budgetController,
  ValueNotifier<int> participants,
  TextEditingController descriptionController,
) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '計画内容を確認してください',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 200))
            .slideX(begin: -0.3),
        
        const SizedBox(height: 24),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfirmRow(
                  theme,
                  Icons.title,
                  'タイトル',
                  titleController.text.isNotEmpty ? titleController.text : '未設定',
                ),
                const Divider(height: 24),
                _buildConfirmRow(
                  theme,
                  Icons.location_on,
                  '目的地',
                  destinationController.text.isNotEmpty ? destinationController.text : '未設定',
                ),
                const Divider(height: 24),
                _buildConfirmRow(
                  theme,
                  Icons.category,
                  'カテゴリー',
                  selectedCategory.value ?? '未設定',
                ),
                const Divider(height: 24),
                _buildConfirmRow(
                  theme,
                  Icons.schedule,
                  '期間',
                  selectedDuration.value ?? '未設定',
                ),
                const Divider(height: 24),
                _buildConfirmRow(
                  theme,
                  Icons.calendar_today,
                  '日程',
                  startDate.value != null && endDate.value != null
                      ? '${startDate.value!.month}/${startDate.value!.day} - ${endDate.value!.month}/${endDate.value!.day}'
                      : '未設定',
                ),
                const Divider(height: 24),
                _buildConfirmRow(
                  theme,
                  Icons.currency_yen,
                  '予算',
                  budgetController.text.isNotEmpty ? '¥${budgetController.text}' : '未設定',
                ),
                const Divider(height: 24),
                _buildConfirmRow(
                  theme,
                  Icons.people,
                  '参加者',
                  '${participants.value}名',
                ),
                if (descriptionController.text.isNotEmpty) ...[
                  const Divider(height: 24),
                  _buildConfirmRow(
                    theme,
                    Icons.description,
                    '説明',
                    descriptionController.text,
                  ),
                ],
              ],
            ),
          ),
        )
            .animate(delay: const Duration(milliseconds: 400))
            .fadeIn(duration: const Duration(milliseconds: 600))
            .slideY(begin: 0.3),
      ],
    ),
  );
}

Widget _buildConfirmRow(
  ThemeData theme,
  IconData icon,
  String label,
  String value,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        color: theme.colorScheme.primary,
        size: 20,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
