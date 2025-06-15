// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $splashRoute,
      $mainRoute,
    ];

RouteBase get $splashRoute => GoRouteData.$route(
      path: '/splash',
      factory: $SplashRouteExtension._fromState,
    );

extension $SplashRouteExtension on SplashRoute {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  String get location => GoRouteData.$location(
        '/splash',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mainRoute => GoRouteData.$route(
      path: '/',
      factory: $MainRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'second',
          factory: $SecondRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'sample',
          factory: $SampleRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'travel-checklist',
          factory: $TravelChecklistRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'detail',
              factory: $ChecklistDetailRouteExtension._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'create-travel-plan',
          factory: $CreateTravelPlanRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'transportation-booking',
          factory: $TransportationBookingRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'pdf-viewer',
          factory: $PdfViewerRouteExtension._fromState,
        ),
      ],
    );

extension $MainRouteExtension on MainRoute {
  static MainRoute _fromState(GoRouterState state) => const MainRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SecondRouteExtension on SecondRoute {
  static SecondRoute _fromState(GoRouterState state) => SecondRoute(
        $extra: state.extra as SecondPageArgs,
      );

  String get location => GoRouteData.$location(
        '/second',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

extension $SampleRouteExtension on SampleRoute {
  static SampleRoute _fromState(GoRouterState state) => SampleRoute(
        $extra: state.extra as SamplePageArgs?,
      );

  String get location => GoRouteData.$location(
        '/sample',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

extension $TravelChecklistRouteExtension on TravelChecklistRoute {
  static TravelChecklistRoute _fromState(GoRouterState state) =>
      const TravelChecklistRoute();

  String get location => GoRouteData.$location(
        '/travel-checklist',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ChecklistDetailRouteExtension on ChecklistDetailRoute {
  static ChecklistDetailRoute _fromState(GoRouterState state) =>
      ChecklistDetailRoute(
        $extra: state.extra as ChecklistItem,
      );

  String get location => GoRouteData.$location(
        '/travel-checklist/detail',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

extension $CreateTravelPlanRouteExtension on CreateTravelPlanRoute {
  static CreateTravelPlanRoute _fromState(GoRouterState state) =>
      const CreateTravelPlanRoute();

  String get location => GoRouteData.$location(
        '/create-travel-plan',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $TransportationBookingRouteExtension on TransportationBookingRoute {
  static TransportationBookingRoute _fromState(GoRouterState state) =>
      TransportationBookingRoute(
        $extra: state.extra as TransportationBooking?,
      );

  String get location => GoRouteData.$location(
        '/transportation-booking',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

extension $PdfViewerRouteExtension on PdfViewerRoute {
  static PdfViewerRoute _fromState(GoRouterState state) => PdfViewerRoute(
        $extra: state.extra as PdfViewerArgs,
      );

  String get location => GoRouteData.$location(
        '/pdf-viewer',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goRouterHash() => r'eb35cb33e29526dbc57108722eb5ab719678ff6f';

/// See also [goRouter].
@ProviderFor(goRouter)
final goRouterProvider = AutoDisposeProvider<GoRouter>.internal(
  goRouter,
  name: r'goRouterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$goRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GoRouterRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
