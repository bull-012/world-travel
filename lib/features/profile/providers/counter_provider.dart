import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter_provider.g.dart';

@riverpod
class Counter extends _$Counter {
  @override
  Future<int> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return 0;
  }

  Future<void> increment() async {
    state = const AsyncLoading();

    await Future<void>.delayed(const Duration(milliseconds: 300));

    state = AsyncData(state.value! + 1);
  }
}
