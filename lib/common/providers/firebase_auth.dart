import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_auth.g.dart';

///「この provider は必ずoverrideされることを前提にしている」という設計を明示するためにエラーを返す
/// 実際の注入は初期化時に呼ばれる
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => throw UnimplementedError();