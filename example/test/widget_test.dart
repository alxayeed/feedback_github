// Basic smoke test for the example app.

import 'package:flutter_test/flutter_test.dart';

import 'package:feedback_github_example/main.dart';

void main() {
  testWidgets('ExampleApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    // The home page should show the 'Feedback Demo' heading.
    expect(find.text('Feedback Demo'), findsOneWidget);
  });
}
