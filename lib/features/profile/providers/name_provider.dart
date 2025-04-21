import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'name_provider.g.dart';

@riverpod
Future<String> userName(Ref ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return '佐藤 太郎';
}
