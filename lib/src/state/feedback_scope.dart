import 'package:flutter/widgets.dart';

import 'feedback_notifier.dart';

/// Provides a [FeedbackNotifier] to all descendants in the widget tree.
///
/// Uses [InheritedNotifier] so any widget that calls [FeedbackScope.of]
/// automatically rebuilds when the notifier changes.
///
/// Placed by [GithubFeedback] — consumers never need to instantiate this
/// directly.
class FeedbackScope extends InheritedNotifier<FeedbackNotifier> {
  const FeedbackScope({
    super.key,
    required FeedbackNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Returns the [FeedbackNotifier] and subscribes the calling widget to
  /// rebuilds.
  ///
  /// Use this inside `build` methods where the widget should react to state
  /// changes (e.g. showing a loading spinner or an error message).
  ///
  /// Throws an [AssertionError] in debug mode if no [FeedbackScope] is found.
  static FeedbackNotifier of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<FeedbackScope>();
    assert(
      scope != null,
      'FeedbackScope.of() called with no FeedbackScope in the widget tree.\n'
      'Make sure your app is wrapped with GithubFeedback(...).',
    );
    return scope!.notifier!;
  }

  /// Returns the [FeedbackNotifier] **without** subscribing to rebuilds.
  ///
  /// Use this inside callbacks and event handlers where you only need to
  /// invoke a method (e.g. `FeedbackScope.read(context).submit(screenshot)`).
  static FeedbackNotifier read(BuildContext context) {
    final scope =
        context.getInheritedWidgetOfExactType<FeedbackScope>();
    assert(
      scope != null,
      'FeedbackScope.read() called with no FeedbackScope in the widget tree.\n'
      'Make sure your app is wrapped with GithubFeedback(...).',
    );
    return scope!.notifier!;
  }
}
