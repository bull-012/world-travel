import 'package:flutter/material.dart';
import 'package:world_travel/features/profile/pages/sample_page.dart'
    show SamplePageArgs;
import 'package:world_travel/pages/second_page.dart' show SecondPageArgs;
import 'package:world_travel/router/router.dart';

class HomeArgs {
  const HomeArgs({
    required this.title,
  });

  final String title;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('仮'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => const SecondRoute(
                $extra: SecondPageArgs(title: 'Page'),
              ).go(context),
              child: const Text('Go to Second Page'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => const SampleRoute(
                $extra: SamplePageArgs(title: 'Sample Profile'),
              ).go(context),
              child: const Text('Go to Sample Profile'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
