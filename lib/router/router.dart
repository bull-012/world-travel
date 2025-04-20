import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:world_travel/pages/home_page.dart';
import 'package:world_travel/pages/second_page.dart'
    show SecondPage, SecondPageArgs;

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
  ],
)
class HomeRoute extends GoRouteData {
  const HomeRoute({required this.$extra});

  final HomeArgs $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return HomePage(args: $extra);
  }
}

class SecondRoute extends GoRouteData {
  const SecondRoute({this.$extra});

  final SecondPageArgs? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SecondPage(
        args: $extra ?? const SecondPageArgs(title: 'Second Page'));
  }
}
