import '../backend/feedback_backend.dart';
import 'feedback_category.dart';

/// Top-level configuration for the `flutter_github_feedback` package.
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
    this.categories = FeedbackCategory.defaults,
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
  /// Defaults to [FeedbackCategory.defaults]. Override to provide
  /// domain-specific categories for your app.
  final List<FeedbackCategory> categories;
}
