import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:world_travel/features/profile/pages/sample_page.dart';
import 'package:world_travel/features/travel_checklist/models/checklist_item.dart';
import 'package:world_travel/features/travel_checklist/pages/checklist_detail_page.dart';
import 'package:world_travel/features/travel_checklist/pages/travel_checklist_page.dart';
import 'package:world_travel/pages/home_page.dart';
import 'package:world_travel/pages/main_scaffold.dart';
import 'package:world_travel/pages/second_page.dart';
import 'package:world_travel/pages/splash_page.dart';

part 'router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: $appRoutes,
  );
}

@TypedGoRoute<SplashRoute>(
  path: '/splash',
)
class SplashRoute extends GoRouteData {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashPage();
  }
}

@TypedGoRoute<MainRoute>(
  path: '/',
  routes: [
    TypedGoRoute<SecondRoute>(
      path: 'second',
    ),
    TypedGoRoute<SampleRoute>(
      path: 'sample',
    ),
    TypedGoRoute<TravelChecklistRoute>(
      path: 'travel-checklist',
      routes: [
        TypedGoRoute<ChecklistDetailRoute>(
          path: 'detail',
        ),
      ],
    ),
  ],
)
class MainRoute extends GoRouteData {
  const MainRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const MainScaffold();
  }
}

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

class TravelChecklistRoute extends GoRouteData {
  const TravelChecklistRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TravelChecklistPage();
  }
}

class ChecklistDetailRoute extends GoRouteData {
  const ChecklistDetailRoute({required this.$extra});

  final ChecklistItem $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChecklistDetailPage(item: $extra);
  }
}
