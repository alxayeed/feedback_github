import 'package:flutter/material.dart';
import '../backend/feedback_backend.dart';
import 'feedback_category.dart';

/// Top-level configuration for the `feedback_github` package.
///
/// Pass this to the [GithubFeedback] root widget:
/// ```dart
/// GithubFeedback(
///   config: FeedbackConfig(
///     enabled: kDebugMode,
///     backend: GitHubFeedbackBackend(
///       token: 'your-token',
///       repoOwner: 'your-org',
///       repoName: 'your-repo',
///     ),
///   ),
///   child: YourApp(),
/// )
/// ```
class FeedbackConfig {
  const FeedbackConfig({
    required this.backend,
    this.enabled = true,
    this.categories = FeedbackCategory.values,
    this.showFloatingButton = true,
    this.themeMode,
  });

  /// The backend responsible for submitting feedback.
  ///
  /// Ships with [GitHubFeedbackBackend] out of the box. Provide your own
  /// implementation of [FeedbackBackend] for custom destinations.
  final FeedbackBackend backend;

  /// Whether the feedback UI is active.
  ///
  /// Tip: set to `kDebugMode` or an environment flag to disable in production.
  /// When `false`, [GithubFeedback] renders its child as-is with no overhead.
  final bool enabled;

  /// The list of categories shown to the user in the feedback sheet.
  ///
  /// Defaults to all [FeedbackCategory] values. Pass a subset to limit
  /// the options shown to the user:
  /// ```dart
  /// categories: [FeedbackCategory.bug, FeedbackCategory.enhancement]
  /// ```
  final List<FeedbackCategory> categories;

  /// Whether to show the draggable floating feedback button automatically on all screens.
  ///
  /// Defaults to `true`. Set to `false` if you want to manually place
  /// the [FeedbackButton] in your layouts.
  final bool showFloatingButton;

  /// The theme mode used to style the feedback UI (ThemeMode.system, ThemeMode.light, or ThemeMode.dark).
  ///
  /// Defaults to [ThemeMode.system].
  final ThemeMode? themeMode;
}
