import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sample_command.g.dart';

class SampleState {
  const SampleState({
    required this.name,
    this.counter = 0,
  });

  final String name;
  final int counter;

  SampleState copyWith({
    String? name,
    int? counter,
  }) {
    return SampleState(
      name: name ?? this.name,
      counter: counter ?? this.counter,
    );
  }
}

@riverpod
class SampleCommand extends _$SampleCommand {
  @override
  SampleState build() {
    return const SampleState(name: 'Sample User');
  }

  void incrementCounter() {
    state = state.copyWith(counter: state.counter + 1);
  }

  // Method to update name
  void updateName(String name) {
    state = state.copyWith(name: name);
    // TODO: query invalidation
  }
}
