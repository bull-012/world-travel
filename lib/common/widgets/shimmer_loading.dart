import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Shimmer効果付きのローディングコンポーネント
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: Colors.white.withValues(alpha: 0.6),
        );
  }
}

/// TravelCard用のShimmerローディング
class ShimmerTravelCard extends StatelessWidget {
  const ShimmerTravelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 画像エリアのShimmer
          const ShimmerLoading(
            width: double.infinity,
            height: 180,
            borderRadius: 0,
          ),
          
          // コンテンツエリア
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル
                Row(
                  children: [
                    const Expanded(
                      child: ShimmerLoading(width: double.infinity, height: 20),
                    ),
                    const SizedBox(width: 12),
                    ShimmerLoading(
                      width: 50,
                      height: 16,
                      borderRadius: 8,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // サブタイトル
                const ShimmerLoading(
                  width: double.infinity,
                  height: 14,
                ),
                const SizedBox(height: 4),
                const ShimmerLoading(
                  width: 200,
                  height: 14,
                ),
                const SizedBox(height: 12),
                
                // タグ
                Row(
                  children: [
                    ShimmerLoading(
                      width: 60,
                      height: 24,
                      borderRadius: 12,
                    ),
                    const SizedBox(width: 8),
                    ShimmerLoading(
                      width: 80,
                      height: 24,
                      borderRadius: 12,
                    ),
                    const SizedBox(width: 8),
                    ShimmerLoading(
                      width: 50,
                      height: 24,
                      borderRadius: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ActivityCard用のShimmerローディング
class ShimmerActivityCard extends StatelessWidget {
  const ShimmerActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ShimmerLoading(
          width: 40,
          height: 40,
          borderRadius: 8,
        ),
        title: const ShimmerLoading(
          width: double.infinity,
          height: 16,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 4),
            ShimmerLoading(
              width: double.infinity,
              height: 12,
            ),
            SizedBox(height: 2),
            ShimmerLoading(
              width: 150,
              height: 12,
            ),
          ],
        ),
        trailing: ShimmerLoading(
          width: 40,
          height: 12,
          borderRadius: 6,
        ),
      ),
    );
  }
}

/// StatCard用のShimmerローディング
class ShimmerStatCard extends StatelessWidget {
  const ShimmerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ShimmerLoading(
              width: 40,
              height: 40,
              borderRadius: 12,
            ),
            const SizedBox(height: 12),
            ShimmerLoading(
              width: 60,
              height: 24,
              borderRadius: 6,
            ),
            const SizedBox(height: 4),
            ShimmerLoading(
              width: 80,
              height: 14,
              borderRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}

/// リスト形式のShimmerローディング
class ShimmerList extends StatelessWidget {
  const ShimmerList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// ページ全体のShimmerローディング
class ShimmerPageLoading extends StatelessWidget {
  const ShimmerPageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヒーロー部分
          ShimmerLoading(
            width: double.infinity,
            height: 200,
            borderRadius: 20,
          ),
          const SizedBox(height: 24),
          
          // セクションタイトル
          ShimmerLoading(
            width: 150,
            height: 24,
            borderRadius: 6,
          ),
          const SizedBox(height: 16),
          
          // グリッド
          Row(
            children: [
              Expanded(child: ShimmerStatCard()),
              const SizedBox(width: 12),
              Expanded(child: ShimmerStatCard()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ShimmerStatCard()),
              const SizedBox(width: 12),
              Expanded(child: ShimmerStatCard()),
            ],
          ),
          const SizedBox(height: 24),
          
          // もう一つのセクション
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoading(
                width: 120,
                height: 24,
                borderRadius: 6,
              ),
              ShimmerLoading(
                width: 60,
                height: 16,
                borderRadius: 6,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // リスト
          ...List.generate(
            5,
            (index) => ShimmerActivityCard(),
          ),
        ],
      ),
    );
  }
}