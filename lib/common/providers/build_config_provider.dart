import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:world_travel/common/models/build_config.dart';

part 'build_config_provider.g.dart';

///「この provider は必ずoverrideされることを前提にしている」という設計を明示するためにエラーを返す
/// 実際の注入は初期化時に呼ばれる
@Riverpod(keepAlive: true)
BuildConfig buildConfig(Ref ref) => throw UnimplementedError();