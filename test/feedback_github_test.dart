import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedback_github/feedback_github.dart';
import 'package:feedback_github/src/feedback/feedback.dart';

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

    await tester.runAsync(() async {
      // Tap the FAB to launch feedback
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(); // Start the screenshot process
      await Future.delayed(const Duration(milliseconds: 200));
      await tester.pump(); // Finish and show BetterFeedback
      await tester.pumpAndSettle();

      // Now, check if the custom feedback sheet is visible
      expect(find.byKey(const Key('feedback_bottom_sheet')), findsOneWidget);

      // Initially, it is not fullscreen, so the screenshot preview Image shouldn't be visible
      expect(find.byType(Image), findsNothing);

      // Let's simulate dragging the bottom sheet up to make it fullscreen
      await tester.dragFrom(const Offset(400, 550), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Now it should be fullscreen, check if the top screenshot preview Image is displayed!
      expect(find.byType(Image), findsOneWidget);
    });
  });

  testWidgets('Snackbar shows on successful submission', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
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
            body: Text('My App Body'),
          ),
        ),
      ),
    );

    // Open feedback sheet (requires runAsync for screenshot)
    await tester.runAsync(() async {
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await Future.delayed(const Duration(milliseconds: 200));
      await tester.pump();
    });
    await tester.pumpAndSettle();

    // Expand to fullscreen so the submit button fits on screen
    final sheetController =
        BetterFeedback.of(tester.element(find.byType(TextField))).sheetController;
    sheetController.jumpTo(1.0);
    await tester.pumpAndSettle();

    // Fill feedback and submit
    await tester.tap(find.textContaining('Bug Report'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Testing success feedback');
    await tester.pumpAndSettle();

    // Tap send
    await tester.runAsync(() async {
      await tester.tap(find.text('Submit Feedback'));
      await tester.pump(); // Start send feedback process
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pump(); // complete screenshot and call submission
    });
    
    // Advance fake time to let the snackbar entrance animation complete
    await tester.pump(const Duration(seconds: 1));

    // Expect snackbar with success message
    expect(find.text('Feedback submitted successfully!'), findsOneWidget);
  });

  testWidgets('Snackbar shows error on failed submission', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      GithubFeedback(
        config: FeedbackConfig(
          enabled: true,
          backend: MockFailureBackend(),
        ),
        child: const MaterialApp(
          home: Scaffold(
            body: Text('My App Body'),
          ),
        ),
      ),
    );

    // Open feedback sheet (requires runAsync for screenshot)
    await tester.runAsync(() async {
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await Future.delayed(const Duration(milliseconds: 200));
      await tester.pump();
    });
    await tester.pumpAndSettle();

    // Expand to fullscreen so the submit button fits on screen
    final sheetController =
        BetterFeedback.of(tester.element(find.byType(TextField))).sheetController;
    sheetController.jumpTo(1.0);
    await tester.pumpAndSettle();

    // Fill feedback and submit
    await tester.tap(find.textContaining('Bug Report'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Testing failure feedback');
    await tester.pumpAndSettle();

    // Tap send
    await tester.runAsync(() async {
      await tester.tap(find.text('Submit Feedback'));
      await tester.pump(); // Start send feedback process
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pump(); // complete screenshot and call submission
    });
    
    // Advance fake time to let the snackbar entrance animation complete
    await tester.pump(const Duration(seconds: 1));

    // Expect snackbar with failure message
    expect(find.textContaining('Failed to submit feedback:'), findsOneWidget);
  });

  testWidgets('Close button in fullscreen mode dismisses feedback sheet', (WidgetTester tester) async {
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

    // Open feedback sheet
    await tester.runAsync(() async {
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await Future.delayed(const Duration(milliseconds: 200));
      await tester.pump();
    });
    await tester.pumpAndSettle();

    // Finder for the close button inside the bottom sheet
    final closeButtonFinder = find.descendant(
      of: find.byKey(const Key('feedback_bottom_sheet')),
      matching: find.byIcon(Icons.close),
    );

    // Verify it is initially not fullscreen, so no close button is visible in header
    expect(closeButtonFinder, findsNothing);

    // Drag the bottom sheet up to make it fullscreen
    await tester.dragFrom(const Offset(400, 550), const Offset(0, -500));
    await tester.pumpAndSettle();

    // Now it should be fullscreen, check that the close button is displayed
    expect(closeButtonFinder, findsOneWidget);

    // Tap the close button
    await tester.tap(closeButtonFinder);
    await tester.pumpAndSettle();

    // The feedback sheet should now be hidden
    expect(find.byKey(const Key('feedback_bottom_sheet')), findsNothing);
  });

  testWidgets('FeedbackTheme updates dynamically when platform brightness changes', (WidgetTester tester) async {
    tester.view.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(() {
      tester.view.platformDispatcher.clearPlatformBrightnessTestValue();
    });

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

    // Open feedback sheet
    await tester.runAsync(() async {
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await Future.delayed(const Duration(milliseconds: 200));
      await tester.pump();
    });
    await tester.pumpAndSettle();

    // Finder for the Material widget inside the bottom sheet
    final sheetMaterialFinder = find.descendant(
      of: find.byKey(const Key('feedback_bottom_sheet')),
      matching: find.byType(Material),
    ).first;

    // Verify background color is light grey (0xFFFAFAFA)
    var material = tester.widget<Material>(sheetMaterialFinder);
    expect(material.color, const Color(0xFFFAFAFA));

    // Change system brightness to dark
    tester.view.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();

    // Verify background color updates to dark grey (0xFF303030)
    material = tester.widget<Material>(sheetMaterialFinder);
    expect(material.color, const Color(0xFF303030));
  });

  testWidgets('DraggableFeedbackButton hides when an explicit FeedbackButton is present', (WidgetTester tester) async {
    bool showExplicitButton = false;
    late StateSetter setPageState;

    await tester.pumpWidget(
      GithubFeedback(
        config: FeedbackConfig(
          enabled: true,
          backend: DummyBackend(),
        ),
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setPageState = setState;
                return Stack(
                  children: [
                    const Text('App Body'),
                    if (showExplicitButton)
                      const FeedbackButton(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    // Default DraggableFeedbackButton should be present
    expect(find.byType(DraggableFeedbackButton), findsOneWidget);
    // There should only be 1 FloatingActionButton in the tree (the default one)
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Now, show the explicit FeedbackButton
    setPageState(() {
      showExplicitButton = true;
    });
    // Pump widgets and let the post frame callback run
    await tester.pump();
    await tester.pumpAndSettle();

    // The default DraggableFeedbackButton should now be hidden (returns SizedBox.shrink)
    // The only FloatingActionButton in the tree should be the explicit one.
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Let's hide the explicit one again and verify DraggableFeedbackButton shows up.
    setPageState(() {
      showExplicitButton = false;
    });
    // Pump widgets and let the post frame callback run
    await tester.pump();
    await tester.pumpAndSettle();

    // DraggableFeedbackButton is active again, so there should still be 1 FloatingActionButton.
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('FeedbackButton colors and icon can be customized', (WidgetTester tester) async {
    const customIcon = Icon(Icons.star, key: Key('custom_icon'));
    const customBg = Colors.purple;
    const customFg = Colors.yellow;

    await tester.pumpWidget(
      GithubFeedback(
        config: FeedbackConfig(
          enabled: true,
          backend: DummyBackend(),
        ),
        child: const MaterialApp(
          home: Scaffold(
            floatingActionButton: FeedbackButton(
              icon: customIcon,
              backgroundColor: customBg,
              foregroundColor: customFg,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('custom_icon')), findsOneWidget);

    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.backgroundColor, customBg);
    expect(fab.foregroundColor, customFg);
  });

  testWidgets('Default floating button can be customized via FeedbackConfig', (WidgetTester tester) async {
    const customIcon = Icon(Icons.star, key: Key('custom_config_icon'));
    const customBg = Colors.blue;
    const customFg = Colors.red;

    await tester.pumpWidget(
      GithubFeedback(
        config: FeedbackConfig(
          enabled: true,
          backend: DummyBackend(),
          icon: customIcon,
          backgroundColor: customBg,
          foregroundColor: customFg,
        ),
        child: const MaterialApp(
          home: Scaffold(
            body: Text('App Body'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('custom_config_icon')), findsOneWidget);

    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.backgroundColor, customBg);
    expect(fab.foregroundColor, customFg);
  });
}

class MockFailureBackend implements FeedbackBackend {
  @override
  Future<void> submit({
    required FeedbackCategory category,
    required String text,
    Uint8List? screenshot,
  }) async {
    throw Exception('API Error');
  }
}

