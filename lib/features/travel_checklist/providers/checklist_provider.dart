import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:world_travel/features/travel_checklist/models/checklist_item.dart';

part 'checklist_provider.g.dart';

/// チェックリストアイテムのリストを提供するプロバイダー
@riverpod
class ChecklistNotifier extends _$ChecklistNotifier {
  @override
  List<ChecklistItem> build() {
    return _defaultChecklistItems;
  }

  /// アイテムの完了状態を更新
  void updateItemStatus(String itemId, {required bool isCompleted}) {
    state = state.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isCompleted: isCompleted);
      }
      return item;
    }).toList();
  }

  /// すべてのアイテムをリセット
  void resetAll() {
    state = _defaultChecklistItems;
  }

  /// 完了したアイテムの数を取得
  int get completedCount => state.where((item) => item.isCompleted).length;

  /// 全アイテム数を取得
  int get totalCount => state.length;

  /// 進捗率を取得（0.0〜1.0）
  double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;
}

/// デフォルトのチェックリストアイテム
final List<ChecklistItem> _defaultChecklistItems = [
  const ChecklistItem(
    id: 'destination',
    question: '行き先は決まりましたか？',
    category: ChecklistCategories.planning,
    icon: Icons.location_on,
    description: '旅行先の決定は最初のステップです',
    tips: [
      '目的に合った行き先を選びましょう',
      '季節や気候を考慮しましょう',
      '予算に合った場所を選びましょう',
    ],
  ),
  const ChecklistItem(
    id: 'planning',
    question: '計画の準備はできましたか？',
    category: ChecklistCategories.planning,
    icon: Icons.event_note,
    description: '詳細な旅行計画を立てましょう',
    tips: [
      '日程表を作成しましょう',
      '観光スポットをリストアップしましょう',
      '移動手段を確認しましょう',
      '宿泊先を予約しましょう',
    ],
  ),
  const ChecklistItem(
    id: 'belongings',
    question: '持ち物は全て揃っていますか？',
    category: ChecklistCategories.belongings,
    icon: Icons.luggage,
    description: '必要な持ち物をチェックしましょう',
    tips: [
      '衣類は天候に合わせて準備',
      '充電器やアダプターを忘れずに',
      '常備薬を準備しましょう',
      'パスポートの有効期限を確認',
    ],
  ),
  const ChecklistItem(
    id: 'safety',
    question: '防犯グッズは揃っていますか？',
    category: ChecklistCategories.safety,
    icon: Icons.security,
    description: '安全な旅行のための準備',
    tips: [
      '貴重品用のポーチを準備',
      'スーツケースの鍵を確認',
      '緊急連絡先をメモしておく',
      '海外旅行保険に加入',
    ],
  ),
  const ChecklistItem(
    id: 'tickets',
    question: '飛行機のチケットをコピーしましたか？',
    category: ChecklistCategories.documents,
    icon: Icons.airplane_ticket,
    description: '重要書類のバックアップ',
    tips: [
      'チケットの印刷またはスクリーンショット',
      'パスポートのコピーを準備',
      'ホテルの予約確認書をコピー',
      'クラウドにもバックアップ',
    ],
  ),
  const ChecklistItem(
    id: 'visa',
    question: 'ビザや必要書類は準備できていますか？',
    category: ChecklistCategories.documents,
    icon: Icons.assignment,
    description: '入国に必要な書類の確認',
    tips: [
      'ビザの要否を確認',
      'パスポートの残存期間を確認',
      '入国カードの記入方法を調べる',
      'ワクチン証明書が必要か確認',
    ],
  ),
  const ChecklistItem(
    id: 'money',
    question: '現金・クレジットカードの準備は？',
    category: ChecklistCategories.money,
    icon: Icons.payment,
    description: '旅行先での支払い準備',
    tips: [
      '現地通貨を少額両替',
      'クレジットカードの限度額確認',
      '海外利用の設定を確認',
      '予備のカードも準備',
    ],
  ),
  const ChecklistItem(
    id: 'health',
    question: '健康面の準備はできていますか？',
    category: ChecklistCategories.health,
    icon: Icons.health_and_safety,
    description: '体調管理と医療準備',
    tips: [
      '常備薬を十分に準備',
      '処方箋のコピーを持参',
      '旅行先の医療事情を調査',
      '緊急連絡先を控える',
    ],
  ),
  const ChecklistItem(
    id: 'communication',
    question: '通信手段の準備はできていますか？',
    category: ChecklistCategories.planning,
    icon: Icons.wifi,
    description: '現地での通信確保',
    tips: [
      'SIMカードやWiFiルーターを準備',
      'ローミング設定を確認',
      '現地の通信事情を調査',
      'オフラインマップをダウンロード',
    ],
  ),
  const ChecklistItem(
    id: 'emergency',
    question: '緊急時の対策は準備できていますか？',
    category: ChecklistCategories.safety,
    icon: Icons.emergency,
    description: '万が一に備えた準備',
    tips: [
      '大使館・領事館の連絡先を控える',
      '緊急連絡先リストを作成',
      '旅行保険の連絡先を確認',
      '家族に旅程を共有',
    ],
  ),
];
