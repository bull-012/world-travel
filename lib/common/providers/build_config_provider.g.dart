// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$buildConfigHash() => r'2d81398cb4435e6baf6efb522105d54ca71179f7';

///「この provider は必ずoverrideされることを前提にしている」という設計を明示するためにエラーを返す
/// 実際の注入は初期化時に呼ばれる
///
/// Copied from [buildConfig].
@ProviderFor(buildConfig)
final buildConfigProvider = Provider<BuildConfig>.internal(
  buildConfig,
  name: r'buildConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$buildConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BuildConfigRef = ProviderRef<BuildConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
