import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_remote_config.g.dart';

///「この provider は必ずoverrideされることを前提にしている」という設計を明示するためにエラーを返す
/// 実際の注入は初期化時に呼ばれる
@Riverpod(keepAlive: true)
FirebaseRemoteConfig firebaseRemoteConfig(Ref ref) => throw UnimplementedError();