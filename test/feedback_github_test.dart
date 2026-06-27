import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedback_github/feedback_github.dart';

class DummyBackend implements FeedbackBackend {
  @override
  Future<void> submit({
    required FeedbackCategory category,
    required String text,
    Uint8List? screenshot,
  }) async {}
}

void main() {
  testWidgets('FeedbackButton renders small variant by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      GithubFeedback(
        config: FeedbackConfig(
          enabled: true,
          backend: DummyBackend(),
        ),
        child: const MaterialApp(
          home: Scaffold(
            floatingActionButton: FeedbackButton(),
          ),
        ),
      ),
    );

    // Expect a FloatingActionButton (small, not extended)
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // FloatingActionButton.extended has type FloatingActionButton, but we can verify it doesn't show label or we can find FloatingActionButton by type and ensure it is not extended
    // In Flutter, FloatingActionButton.extended uses the same class FloatingActionButton but isExtended is true.
    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.isExtended, isFalse);
  });

  testWidgets('FeedbackButton renders big variant when specified', (WidgetTester tester) async {
    await tester.pumpWidget(
      GithubFeedback(
        config: FeedbackConfig(
          enabled: true,
          backend: DummyBackend(),
        ),
        child: const MaterialApp(
          home: Scaffold(
            floatingActionButton: FeedbackButton(
              variant: FeedbackButtonVariant.big,
            ),
          ),
        ),
      ),
    );

    // Expect a FloatingActionButton.extended
    expect(find.byType(FloatingActionButton), findsOneWidget);
    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.isExtended, isTrue);
  });

  testWidgets('FeedbackButton is hidden when GithubFeedback is disabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      GithubFeedback(
        config: FeedbackConfig(
          enabled: false,
          backend: DummyBackend(),
        ),
        child: const MaterialApp(
          home: Scaffold(
            floatingActionButton: FeedbackButton(),
          ),
        ),
      ),
    );

    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
