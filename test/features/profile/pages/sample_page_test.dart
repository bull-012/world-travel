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

    await tester.pumpAndSettle();

    // Verify that the title is displayed
    expect(find.text('Test Sample Page'), findsOneWidget);
  });
}
