import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/common/app_initializer.dart';
import 'package:world_travel/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final (overrideProviders: overrideProviders) =
      await AppInitializer.initialize();

  runApp(
    ProviderScope(
      overrides: overrideProviders,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'World Travel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
