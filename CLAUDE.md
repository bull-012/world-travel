# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Development Workflow
```bash
# Install dependencies
fvm flutter pub get

# Generate code (required after provider/router changes)
fvm dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous code generation
fvm dart run build_runner watch --delete-conflicting-outputs

# Format code (enforced by CI)
fvm dart format .

# Run static analysis
fvm flutter analyze

# Run tests
fvm flutter test
```

### Flutter Version Management
This project uses FVM with Flutter 3.32.0. The version is specified in `.fvmrc`.

### Platform Builds
```bash
# Android
fvm flutter build apk --dart-define-from-file=dart_defines/qa.env

# iOS
fvm flutter build ios --release --no-codesign

# Web
fvm flutter build web

# Widgetbook (for component documentation)
fvm flutter build web -t widgetbook/main.dart --release
```

## Architecture Overview

### CQRS Pattern Implementation
This project implements Command Query Responsibility Segregation (CQRS):

- **Commands** (`lib/features/*/command/`): Handle state mutations and side effects
  - Use Riverpod class providers extending generated base classes
  - Example: `CounterCommand` for counter increments
  
- **Queries/Providers** (`lib/features/*/providers/`): Handle data fetching and caching
  - Use `AsyncValue<T>` for loading/error/data states
  - Auto-invalidate and re-fetch as needed

### Riverpod as Cache Library
Inspired by React Query/TanStack Query:
- Providers handle async operations with automatic caching
- `AsyncValue` provides loading, error, and data states
- State invalidation and background refetching
- Server state vs client state separation

### Code Generation Requirements
Always run code generation after modifying:
- Riverpod providers (files with `@riverpod` annotation)
- Router definitions (`router.dart`)
- Any file importing `riverpod_annotation`

Generated files (`.g.dart`) should never be manually edited.

### Key Architectural Patterns

**App Initialization**: `lib/common/app_initializer.dart` sets up provider overrides for:
- SharedPreferences
- Build configuration  
- Firebase instances (when enabled)

**Feature Structure**: Domain-based organization under `lib/features/`:
```
features/
  profile/
    command/     # State mutations
    providers/   # Data fetching  
    hooks/       # Local state/forms
    pages/       # UI components
    models/      # Data models
```

**Routing**: Type-safe GoRouter with code generation:
- Routes defined as classes extending `GoRouteData`
- Nested route support
- Type-safe navigation with `const SampleRoute().go(context)`

**Form Management**: Custom hooks using `flutter_hooks` and `formz`:
- Example: `useSingleNameForm()` for reusable form logic
- Validation and state management built-in

## Testing

Tests use `flutter_test` with additional packages:
- `mocktail` for mocking
- `firebase_auth_mocks` for Firebase Auth testing  
- `alchemist` for visual regression testing
- Provider testing requires wrapping with `ProviderScope`

### Testing Patterns

#### Provider Testing
```dart
testWidgets('Counter provider increments correctly', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Consumer(builder: (context, ref, _) {
          final counter = ref.watch(counterProvider);
          return switch (counter) {
            AsyncData(:final value) => Text('$value'),
            AsyncLoading() => const CircularProgressIndicator(),
            AsyncError() => const Text('Error'),
          };
        }),
      ),
    ),
  );
  
  await tester.pumpAndSettle();
  expect(find.text('0'), findsOneWidget);
});
```

#### Command Testing
```dart
test('CounterCommand increments state', () async {
  final container = ProviderContainer();
  final command = container.read(counterCommandProvider.notifier);
  
  expect(command.state.counter, 0);
  
  await command.incrementCounter();
  expect(command.state.counter, 1);
  
  container.dispose();
});
```

#### Form Hook Testing
```dart
testWidgets('Name form validates input', (tester) async {
  late UseSingleNameForm nameForm;
  
  await tester.pumpWidget(
    MaterialApp(
      home: HookBuilder(builder: (context) {
        nameForm = useSingleNameForm();
        return TextField(
          controller: nameForm.nameForm.textEditingController,
          onChanged: nameForm.nameForm.dirty,
        );
      }),
    ),
  );
  
  // Test empty validation
  nameForm.nameForm.dirty('');
  expect(nameForm.nameForm.input.error, NameInputError.empty);
  
  // Test valid input
  nameForm.nameForm.dirty('John');
  expect(nameForm.nameForm.input.error, null);
  expect(nameForm.name(), 'John');
});
```

#### Widgetbook Testing
```dart
// Add to widgetbook_app.dart
WidgetbookComponent(
  name: 'MyComponent',
  useCases: [
    WidgetbookUseCase(
      name: 'Default State',
      builder: (context) => const RouterWrapper(
        child: MyComponent(),
      ),
    ),
    WidgetbookUseCase(
      name: 'Loading State', 
      builder: (context) => ProviderScope(
        overrides: [
          myDataProvider.overrideWith((ref) => 
            const AsyncLoading<MyData>()),
        ],
        child: const RouterWrapper(
          child: MyComponent(),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Error State',
      builder: (context) => ProviderScope(
        overrides: [
          myDataProvider.overrideWith((ref) => 
            AsyncError('Error message', StackTrace.current)),
        ],
        child: const RouterWrapper(
          child: MyComponent(),
        ),
      ),
    ),
  ],
),

## Firebase Integration

Firebase services are set up but partially commented out in `app_initializer.dart`:
- Authentication
- Remote Config
- Messaging  
- Analytics
- Crashlytics

Refer to docs in `docs/` folder for setup instructions.

### Firebase Provider Pattern
```dart
// Define provider that throws by default
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => throw UnimplementedError();

// Override in app_initializer.dart
final firebaseAuthInstance = FirebaseAuth.instance;
overrides.add(
  firebaseAuthProvider.overrideWithValue(firebaseAuthInstance),
);

// Use in other providers
@riverpod
Stream<User?> authState(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
}

// Mock in tests
final mockAuth = MockFirebaseAuth();
ProviderScope(
  overrides: [
    firebaseAuthProvider.overrideWithValue(mockAuth),
  ],
  child: MyApp(),
);
```

## iOS Dependencies

Uses Swift Package Manager (SPM) instead of CocoaPods for iOS dependencies. This is configured in the Xcode project and provides better Xcode integration and faster builds.

### SPM Troubleshooting
```bash
# Clear SPM cache
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/org.swift.swiftpm

# Reset package dependencies in Xcode
# File > Packages > Reset Package Caches

# Clean and rebuild
fvm flutter clean
cd ios
xcodebuild clean
cd ..
fvm flutter pub get
```

## Common Development Patterns

### Adding a New Feature
1. Create feature directory: `lib/features/my_feature/`
2. Add subdirectories: `command/`, `providers/`, `hooks/`, `pages/`, `models/`
3. Implement CQRS pattern with commands and providers
4. Add routes to `router.dart`
5. Generate code: `dart run build_runner build --delete-conflicting-outputs`
6. Add tests and Widgetbook stories

### Provider Lifecycle Management
```dart
// Keep provider alive across widget rebuilds
@Riverpod(keepAlive: true)
MyData myData(Ref ref) async {
  // This provider won't be disposed when no longer watched
}

// Auto-dispose when no longer watched (default)
@riverpod
MyData myTempData(Ref ref) async {
  // This provider will be disposed when no widgets watch it
}

// Manual disposal
ref.onDispose(() {
  // Cleanup logic here
});
```

### Error Handling Patterns
```dart
// In providers
@riverpod
Future<Data> myData(Ref ref) async {
  try {
    return await api.fetchData();
  } on ApiException catch (e) {
    // Log error
    ref.read(loggingProvider).logError(e);
    // Re-throw or return default
    throw Exception('Failed to fetch data: ${e.message}');
  }
}

// In UI
final dataAsync = ref.watch(myDataProvider);

return switch (dataAsync) {
  AsyncData(:final value) => DataWidget(data: value),
  AsyncLoading() => const LoadingWidget(),
  AsyncError(:final error) => ErrorWidget(
    error: error,
    onRetry: () => ref.refresh(myDataProvider),
  ),
};
```

## Troubleshooting

### Common Issues

#### "No part directive found" Error
```dart
// Add this to files using @riverpod
part 'filename.g.dart';
```

#### Build Runner Conflicts
```bash
# Kill existing build runner process
ps aux | grep build_runner
kill <process_id>

# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### Provider Override Not Working
```dart
// Ensure provider is properly overridden
// In app_initializer.dart
overrides.add(
  myProviderProvider.overrideWithValue(myInstance),
);

// Not in global scope
final provider = Provider((ref) => MyClass());
```

#### iOS Build Errors
```bash
# Clean Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset Flutter iOS build
fvm flutter clean
rm -rf ios/Pods ios/Podfile.lock
fvm flutter pub get
cd ios && pod install --repo-update
```

### Performance Tips

- Use `keepAlive: true` for expensive computations
- Implement proper `select` for partial rebuilds
- Use `AsyncValueGroup` for combining multiple async operations
- Avoid creating providers in widget build methods
- Use `ref.read()` for one-time access, `ref.watch()` for reactive access