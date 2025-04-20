import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:world_travel/router/router.dart';
import 'package:world_travel/pages/home_page.dart' show HomeArgs;

class SecondPageArgs {
  const SecondPageArgs({
    required this.title,
  });

  final String title;
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key, required this.args});

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
              onPressed: () => const HomeRoute(
                $extra: HomeArgs(title: 'Back from Second Page with Page'),
              ).go(context),
              child: const Text('Go back to Home Page'),
            ),
          ],
        ),
      ),
    );
  }
}
