// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$checklistNotifierHash() => r'49d3acfc9941e0d8d7b415692a4cfbb3f25e4356';

/// チェックリストアイテムのリストを提供するプロバイダー
///
/// Copied from [ChecklistNotifier].
@ProviderFor(ChecklistNotifier)
final checklistNotifierProvider = AutoDisposeNotifierProvider<ChecklistNotifier,
    List<ChecklistItem>>.internal(
  ChecklistNotifier.new,
  name: r'checklistNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$checklistNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChecklistNotifier = AutoDisposeNotifier<List<ChecklistItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
