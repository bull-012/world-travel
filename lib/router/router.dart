import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:world_travel/features/profile/pages/sample_page.dart';
import 'package:world_travel/pages/home_page.dart';
import 'package:world_travel/pages/second_page.dart';

part 'router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: $appRoutes,
  );
}

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<SecondRoute>(
      path: 'second',
    ),
    TypedGoRoute<SampleRoute>(
      path: 'sample',
    ),
  ],
)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

class SecondRoute extends GoRouteData {
  const SecondRoute({required this.$extra});

  final SecondPageArgs $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SecondPage(
      args: $extra,
    );
  }
}

class SampleRoute extends GoRouteData {
  const SampleRoute({this.$extra});

  final SamplePageArgs? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SamplePage(
      args: $extra ?? const SamplePageArgs(title: 'Sample Profile'),
    );
  }
}
