import 'package:flutter/material.dart';

/// チェックリストアイテムのデータモデル
class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.question,
    required this.category,
    required this.icon,
    this.description,
    this.tips = const [],
    this.isCompleted = false,
  });

  final String id;
  final String question;
  final String category;
  final IconData icon;
  final String? description;
  final List<String> tips;
  final bool isCompleted;

  ChecklistItem copyWith({
    String? id,
    String? question,
    String? category,
    IconData? icon,
    String? description,
    List<String>? tips,
    bool? isCompleted,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      question: question ?? this.question,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      tips: tips ?? this.tips,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// カテゴリー定数
class ChecklistCategories {
  static const String planning = '計画';
  static const String documents = '書類';
  static const String belongings = '持ち物';
  static const String safety = '安全対策';
  static const String health = '健康';
  static const String money = 'お金';
}
