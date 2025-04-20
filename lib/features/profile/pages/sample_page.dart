import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/common/extensions/async_value_group.dart';
import 'package:world_travel/features/profile/hooks/use_name_form.dart';
import 'package:world_travel/features/profile/providers/counter_provider.dart';
import 'package:world_travel/features/profile/providers/name_provider.dart';

class SamplePageArgs {
  const SamplePageArgs({
    required this.title,
  });

  final String title;
}

class SamplePage extends HookConsumerWidget {
  const SamplePage({
    required this.args,
    super.key,
  });

  final SamplePageArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameForm = useSingleNameForm();
    final nameAsync = ref.watch(userNameProvider);
    final counterAsync = ref.watch(counterProvider);

    final mergedData = AsyncValueGroup.group2(
      nameAsync,
      counterAsync,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameForm.nameForm.textEditingController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
              onChanged: nameForm.nameForm.dirty,
              key: const Key('nameTextField'),
            ),
            const SizedBox(height: 16),
            switch (mergedData) {
              AsyncData(:final value) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (nameForm.name().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Hello, ${nameForm.name()}!',
                          style: Theme.of(context).textTheme.titleLarge,
                          key: const Key('nameDisplay'),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Hello, $userName!',
                          style: Theme.of(context).textTheme.titleLarge,
                          key: const Key('nameDisplay'),
                        ),
                      ),
                    Text(
                      'Counter: ${value.$2}',
                      style: Theme.of(context).textTheme.headlineSmall,
                      key: const Key('counterText'),
                    ),
                    const SizedBox(height: 16),

                    // Increment button
                    ElevatedButton(
                      onPressed: () {
                        ref.read(counterProvider.notifier).increment();
                      },
                      key: const Key('incrementButton'),
                      child: const Text('Increment Counter'),
                    ),
                  ],
                ),
              AsyncLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              AsyncError(error: final error) => Center(
                  child: Text('Error: $error'),
                ),
              _ => throw UnimplementedError(),
            },
          ],
        ),
      ),
    );
  }
}
