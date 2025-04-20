import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/features/profile/pages/sample_page.dart';

void main() {
  testWidgets('SamplePage displays name input and counter',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SamplePage(
            args: SamplePageArgs(title: 'Test Sample Page'),
          ),
        ),
      ),
    );

    // Verify that the title is displayed
    expect(find.text('Test Sample Page'), findsOneWidget);

    // Verify that the name input field is displayed
    expect(find.byKey(const Key('nameTextField')), findsOneWidget);

    // Verify that the counter text is displayed
    expect(find.byKey(const Key('counterText')), findsOneWidget);
    expect(find.text('Counter: 0'), findsOneWidget);

    // Enter text in the name field
    await tester.enterText(find.byKey(const Key('nameTextField')), 'Test User');
    await tester.pump();

    // Verify that the entered name is displayed
    expect(find.text('Hello, Test User!'), findsOneWidget);

    // Tap the increment button
    await tester.tap(find.byKey(const Key('incrementButton')));
    await tester.pump();

    // Verify that the counter has been incremented
    expect(find.text('Counter: 1'), findsOneWidget);
  });
}
