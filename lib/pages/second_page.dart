import 'package:flutter/material.dart';
import 'package:world_travel/router/router.dart';

class SecondPageArgs {
  const SecondPageArgs({
    required this.title,
  });

  final String title;
}

class SecondPage extends StatelessWidget {
  const SecondPage({required this.args, super.key});

  final SecondPageArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(args.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is the Second Page',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => const HomeRoute().go(context),
              child: const Text('Go back to Home Page'),
            ),
          ],
        ),
      ),
    );
  }
}
