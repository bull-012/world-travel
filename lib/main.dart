import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:world_travel/common/app_initializer.dart';
import 'package:world_travel/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MapBox with access token from environment variable
  const mapboxToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  if (mapboxToken.isEmpty) {
    debugPrint('ERROR: MAPBOX_ACCESS_TOKEN not found in environment variables');
    debugPrint(
      'Make sure to run with --dart-define-from-file=dart_defines/[env].env',
    );
  } else {
    try {
      MapboxOptions.setAccessToken(mapboxToken);
      debugPrint('MapBox initialized with token from environment');

      // Verify token was set
      final verifyToken = await MapboxOptions.getAccessToken();
      if (verifyToken.isEmpty) {
        debugPrint(
          'WARNING: MapBox token verification failed - token is empty',
        );
      } else {
        debugPrint('MapBox token verified: ${verifyToken.substring(0, 10)}...');
      }
    } on Exception catch (e) {
      debugPrint('ERROR: Failed to set MapBox token: $e');
    }
  }

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
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      routerConfig: router,
    );
  }

  ThemeData _buildLightTheme() {
    const travelBlue = Color(0xFF1E88E5); // 海の青
    const skyBlue = Color(0xFF42A5F5); // 空の青
    const surfaceBlue = Color(0xFFF3F8FF); // 薄い青

    final colorScheme = ColorScheme.fromSeed(
      seedColor: travelBlue,
      primary: travelBlue,
      primaryContainer: const Color(0xFFE3F2FD),
      secondary: skyBlue,
      secondaryContainer: const Color(0xFFE1F5FE),
      surface: Colors.white,
      surfaceContainerHighest: surfaceBlue,
      outline: const Color(0xFFE0E0E0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // タイポグラフィ設定（日本語最適化）
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.1,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
        ),
      ),

      // カード設定
      cardTheme: const CardThemeData(
        elevation: 2,
        shadowColor: Color.fromRGBO(30, 136, 229, 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // AppBar設定
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A1A),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),

      // ボタン設定
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: const Color.fromRGBO(30, 136, 229, 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // FloatingActionButton設定
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // NavigationBar設定
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        elevation: 3,
        shadowColor: const Color.fromRGBO(30, 136, 229, 0.1),
        backgroundColor: Colors.white,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
              height: 1.3,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.outline,
            height: 1.3,
          );
        }),
      ),

      // InputDecoration設定
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromRGBO(224, 224, 224, 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // ListTile設定
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // BottomNavigationBar設定
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: travelBlue,
        unselectedItemColor: Color(0xFF757575),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const travelBlue = Color(0xFF42A5F5);
    const darkSurface = Color(0xFF121212);
    const darkSurfaceVariant = Color(0xFF1E1E1E);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: travelBlue,
      brightness: Brightness.dark,
      primary: travelBlue,
      primaryContainer: const Color(0xFF1565C0),
      secondary: const Color(0xFF81C784),
      surface: darkSurface,
      surfaceContainerHighest: darkSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildLightTheme().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
