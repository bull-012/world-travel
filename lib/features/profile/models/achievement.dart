import 'package:flutter/material.dart';

/// 称号・実績の種類
enum AchievementType {
  travel, // 旅行関連
  adventure, // 冒険関連
  social, // ソーシャル関連
  special, // 特別な称号
}

/// 称号・実績のモデル
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.requirement,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    this.maxProgress = 1,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementType type;
  final String requirement;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    AchievementType? type,
    String? requirement,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? maxProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      requirement: requirement ?? this.requirement,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
    );
  }

  double get progressPercentage =>
      maxProgress > 0 ? progress / maxProgress : 0.0;
}

/// デフォルトの称号リスト
final List<Achievement> defaultAchievements = [
  // 旅行関連
  Achievement(
    id: 'first_trip',
    title: '初心者旅行者',
    description: '初めての旅行を完了',
    icon: Icons.flight_takeoff,
    color: Colors.blue,
    type: AchievementType.travel,
    requirement: '1回の旅行を完了',
    isUnlocked: true,
    unlockedAt: DateTime(2024, 1, 15),
  ),
  Achievement(
    id: 'country_explorer',
    title: '国際探検家',
    description: '5つの国を訪問',
    icon: Icons.public,
    color: Colors.green,
    type: AchievementType.travel,
    requirement: '5ヶ国を訪問',
    isUnlocked: true,
    unlockedAt: DateTime(2024, 3, 20),
    progress: 12,
    maxProgress: 5,
  ),
  const Achievement(
    id: 'world_traveler',
    title: '世界旅行者',
    description: '15の国を制覇',
    icon: Icons.travel_explore,
    color: Colors.orange,
    type: AchievementType.travel,
    requirement: '15ヶ国を訪問',
    progress: 12,
    maxProgress: 15,
  ),
  const Achievement(
    id: 'globe_trotter',
    title: 'グローブトロッター',
    description: '全大陸を制覇',
    icon: Icons.language,
    color: Colors.purple,
    type: AchievementType.travel,
    requirement: '7大陸すべてを訪問',
    progress: 4,
    maxProgress: 7,
  ),

  // 冒険関連
  Achievement(
    id: 'adventurous_spirit',
    title: '冒険精神',
    description: '初めてのアクティビティ体験',
    icon: Icons.hiking,
    color: Colors.brown,
    type: AchievementType.adventure,
    requirement: 'アウトドアアクティビティを体験',
    isUnlocked: true,
    unlockedAt: DateTime(2024, 2, 10),
  ),
  const Achievement(
    id: 'thrill_seeker',
    title: 'スリルシーカー',
    description: '5つの極限アクティビティを体験',
    icon: Icons.paragliding,
    color: Colors.red,
    type: AchievementType.adventure,
    requirement: 'バンジージャンプ、スカイダイビングなど',
    progress: 2,
    maxProgress: 5,
  ),

  // ソーシャル関連
  const Achievement(
    id: 'social_butterfly',
    title: 'ソーシャルバタフライ',
    description: '10人の旅行仲間を作る',
    icon: Icons.people,
    color: Colors.pink,
    type: AchievementType.social,
    requirement: '10人の友達と旅行',
    progress: 6,
    maxProgress: 10,
  ),
  Achievement(
    id: 'photo_master',
    title: 'フォトマスター',
    description: '100枚の旅行写真を投稿',
    icon: Icons.camera_alt,
    color: Colors.indigo,
    type: AchievementType.social,
    requirement: '写真を100枚投稿',
    isUnlocked: true,
    unlockedAt: DateTime(2024, 4, 5),
    progress: 156,
    maxProgress: 100,
  ),

  // 特別な称号
  Achievement(
    id: 'early_adopter',
    title: 'アーリーアダプター',
    description: 'アプリの初期ユーザー',
    icon: Icons.star,
    color: Colors.amber,
    type: AchievementType.special,
    requirement: 'β版から利用',
    isUnlocked: true,
    unlockedAt: DateTime(2023, 12),
  ),
  const Achievement(
    id: 'master_traveler',
    title: 'マスタートラベラー',
    description: '究極の旅行者',
    icon: Icons.emoji_events,
    color: Colors.deepOrange,
    type: AchievementType.special,
    requirement: '全ての基本称号を獲得',
    progress: 5,
    maxProgress: 8,
  ),
];
