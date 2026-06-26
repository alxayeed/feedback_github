import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

import '../state/feedback_scope.dart';

/// A pre-built [FloatingActionButton] that launches the feedback flow.
///
/// Drop this into your [Scaffold.floatingActionButton] — no other wiring
/// needed as long as your app is wrapped with [GithubFeedback]:
///
/// ```dart
/// Scaffold(
///   floatingActionButton: FeedbackButton(),
///   body: ...,
/// )
/// ```
///
/// The button is invisible (`SizedBox.shrink`) when
/// [FeedbackConfig.enabled] is `false`, so it is safe to leave in the
/// widget tree in production builds.
///
/// **Customisation** — swap the icon or label as needed:
/// ```dart
/// FeedbackButton(
///   icon:  Icon(Icons.bug_report_outlined),
///   label: Text('Report a bug'),
/// )
/// ```
class FeedbackButton extends StatelessWidget {
  const FeedbackButton({
    super.key,
    this.icon = const Icon(Icons.feedback_outlined),
    this.label = const Text('Feedback'),
  });

  /// Icon shown on the extended FAB. Defaults to `Icons.feedback_outlined`.
  final Widget icon;

  /// Label shown on the extended FAB. Defaults to `"Feedback"`.
  final Widget label;

  @override
  Widget build(BuildContext context) {
    // Use of() so the button reacts if enabled changes at runtime.
    final notifier = FeedbackScope.of(context);

    if (!notifier.config.enabled) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      // Explicit heroTag prevents Hero conflicts when consumers also have FABs.
      heroTag: 'feedback_github_fab',
      onPressed: () => _showFeedback(context),
      icon: icon,
      label: label,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _showFeedback(BuildContext context) {
    // Use read() inside a callback — no rebuild subscription needed.
    final config = FeedbackScope.read(context).config;

    BetterFeedback.of(context).show((UserFeedback feedback) async {
      // The sheet stores the selected category in extras.
      final category = feedback.extra?['category'] as String? ??
          config.categories.first.label;

      await config.backend.submit(
        category: category,
        text: feedback.text,
        screenshot: feedback.screenshot,
      );
    });
  }
}
