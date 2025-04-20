import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter_command.g.dart';

class CounterState {
  const CounterState({
    this.counter = 0,
  });

  final int counter;

  CounterState copyWith({
    int? counter,
  }) {
    return CounterState(
      counter: counter ?? this.counter,
    );
  }
}

// Command provider using @riverpod class provider
@riverpod
class CounterCommand extends _$CounterCommand {
  @override
  CounterState build() {
    return const CounterState();
  }

  // Method to increment counter
  Future<void> incrementCounter() async {
    // Simulate a network request
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Update the state
    state = state.copyWith(counter: state.counter + 1);
  }
}
