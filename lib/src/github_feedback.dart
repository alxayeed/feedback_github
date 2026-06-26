import 'package:feedback/feedback.dart';
import 'package:flutter/widgets.dart';

import 'config/feedback_config.dart';
import 'state/feedback_notifier.dart';
import 'state/feedback_scope.dart';
import 'ui/custom_feedback_sheet.dart';

/// Root widget that activates the `feedback_github` package.
///
/// Wrap your [MaterialApp] (or the topmost widget in your tree) with this:
///
/// ```dart
/// GithubFeedback(
///   config: FeedbackConfig(
///     enabled: kDebugMode,
///     backend: GitHubFeedbackBackend(
///       token:     'ghp_yourToken',
///       repoOwner: 'your-org',
///       repoName:  'your-repo',
///       branch:    'feedback',
///     ),
///   ),
///   child: MaterialApp(...),
/// )
/// ```
///
/// When [FeedbackConfig.enabled] is `false` this widget is a transparent
/// pass-through — it renders [child] with absolutely no overhead, so it is
/// safe to leave in the tree for production builds (just set `enabled: false`
/// or `enabled: kDebugMode`).
class GithubFeedback extends StatefulWidget {
  const GithubFeedback({
    super.key,
    required this.config,
    required this.child,
  });

  /// Package configuration. See [FeedbackConfig] for all options.
  final FeedbackConfig config;

  /// Your app's root widget (typically [MaterialApp]).
  final Widget child;

  @override
  State<GithubFeedback> createState() => _GithubFeedbackState();
}

class _GithubFeedbackState extends State<GithubFeedback> {
  late FeedbackNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = FeedbackNotifier(config: widget.config);
  }

  @override
  void didUpdateWidget(GithubFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-create the notifier when config is swapped (e.g. during hot-reload).
    if (oldWidget.config != widget.config) {
      _notifier.dispose();
      _notifier = FeedbackNotifier(config: widget.config);
    }
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // When disabled, render child with zero overhead — no BetterFeedback,
    // no InheritedWidget, no notifier in the tree.
    if (!widget.config.enabled) return widget.child;

    return FeedbackScope(
      notifier: _notifier,
      child: BetterFeedback(
        feedbackBuilder: buildCustomFeedbackSheet(widget.config),
        child: widget.child,
      ),
    );
  }
}
