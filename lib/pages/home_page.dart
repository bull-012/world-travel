import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:world_travel/router/router.dart';
import 'package:world_travel/pages/second_page.dart' show SecondPageArgs;

class HomeArgs {
  const HomeArgs({
    required this.title,
  });

  final String title;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.args});

  final HomeArgs args;

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
        title: Text(widget.args.title),
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
