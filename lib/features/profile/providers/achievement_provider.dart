import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:world_travel/features/profile/models/achievement.dart';

part 'achievement_provider.g.dart';

@riverpod
class AchievementNotifier extends _$AchievementNotifier {
  @override
  List<Achievement> build() {
    return defaultAchievements;
  }

  /// 称号を解除する
  void unlockAchievement(String achievementId) {
    state = state.map((achievement) {
      if (achievement.id == achievementId && !achievement.isUnlocked) {
        return achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
      return achievement;
    }).toList();
  }

  /// 進捗を更新する
  void updateProgress(String achievementId, int newProgress) {
    state = state.map((achievement) {
      if (achievement.id == achievementId) {
        final updatedAchievement = achievement.copyWith(progress: newProgress);
        
        // 進捗が最大に達したら自動的に解除
        if (newProgress >= achievement.maxProgress && !achievement.isUnlocked) {
          return updatedAchievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
        }
        
        return updatedAchievement;
      }
      return achievement;
    }).toList();
  }

  /// 解除済みの称号を取得
  List<Achievement> get unlockedAchievements {
    return state.where((achievement) => achievement.isUnlocked).toList();
  }

  /// 最新の称号を取得（プロフィールに表示用）
  Achievement? get latestAchievement {
    final unlocked = unlockedAchievements;
    if (unlocked.isEmpty) return null;
    
    unlocked.sort((a, b) => (b.unlockedAt ?? DateTime(0)).compareTo(a.unlockedAt ?? DateTime(0)));
    return unlocked.first;
  }

  /// タイプ別の称号数
  int getUnlockedCountByType(AchievementType type) {
    return state.where((a) => a.type == type && a.isUnlocked).length;
  }

  /// 総称号数
  int get totalUnlockedCount => unlockedAchievements.length;
}