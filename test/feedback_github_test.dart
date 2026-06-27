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
          showFloatingButton: false,
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
          showFloatingButton: false,
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

  testWidgets('DraggableFeedbackButton is shown by default when GithubFeedback is enabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      GithubFeedback(
        config: FeedbackConfig(
          enabled: true,
          backend: DummyBackend(),
        ),
        child: const MaterialApp(
          home: Scaffold(
            body: Text('Hello'),
          ),
        ),
      ),
    );

    expect(find.byType(DraggableFeedbackButton), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('DraggableFeedbackButton is NOT shown when showFloatingButton is false', (WidgetTester tester) async {
    await tester.pumpWidget(
      GithubFeedback(
        config: FeedbackConfig(
          enabled: true,
          showFloatingButton: false,
          backend: DummyBackend(),
        ),
        child: const MaterialApp(
          home: Scaffold(
            body: Text('Hello'),
          ),
        ),
      ),
    );

    expect(find.byType(DraggableFeedbackButton), findsNothing);
  });

  testWidgets('DraggableFeedbackButton can be dragged around', (WidgetTester tester) async {
    // Set a fixed screen size so boundaries are deterministic
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GithubFeedback(
        config: FeedbackConfig(
          enabled: true,
          backend: DummyBackend(),
        ),
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(),
          ),
        ),
      ),
    );

    expect(find.byType(DraggableFeedbackButton), findsOneWidget);
    
    final initialCenter = tester.getCenter(find.byType(FloatingActionButton));
    
    // Drag it left and up
    await tester.drag(find.byType(FloatingActionButton), const Offset(-150, -150));
    await tester.pumpAndSettle();
    
    final newCenter = tester.getCenter(find.byType(FloatingActionButton));
    expect(newCenter.dx, lessThan(initialCenter.dx));
    expect(newCenter.dy, lessThan(initialCenter.dy));
  });

  testWidgets('Fullscreen bottom sheet shows screenshot preview', (WidgetTester tester) async {
    await tester.pumpWidget(
      GithubFeedback(
        config: FeedbackConfig(
          enabled: true,
          backend: DummyBackend(),
        ),
        child: const MaterialApp(
          home: Scaffold(
            body: Text('My App Body'),
          ),
        ),
      ),
    );

    // Tap the FAB to launch feedback
    await tester.runAsync(() async {
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(); // Start the screenshot process and endOfFrame wait
      await Future.delayed(const Duration(milliseconds: 100));
      await tester.pump(); // Finish endOfFrame and show BetterFeedback
      await tester.pumpAndSettle(); // Settle all animations
    });

    // Now, check if the custom feedback sheet is visible
    expect(find.byKey(const Key('feedback_bottom_sheet')), findsOneWidget);

    // Initially, it is not fullscreen, so the screenshot preview Image shouldn't be visible
    expect(find.byType(Image), findsNothing);

    // Let's simulate dragging the bottom sheet up to make it fullscreen
    // Drag it all the way up from the bottom center of the screen
    await tester.dragFrom(const Offset(400, 550), const Offset(0, -500));
    await tester.pumpAndSettle();

    // Now it should be fullscreen, check if the top screenshot preview Image is displayed!
    expect(find.byType(Image), findsOneWidget);
  });
}
