/// GitHub-mapped feedback categories.
///
/// Each value carries its own [emoji], [displayLabel], and [githubLabel] —
/// no strings or emojis needed from the consumer.
///
/// ```dart
/// // Use all categories (default)
/// FeedbackConfig(categories: FeedbackCategory.values, ...)
///
/// // Or cherry-pick
/// FeedbackConfig(
///   categories: [FeedbackCategory.bug, FeedbackCategory.enhancement],
///   ...
/// )
/// ```
enum FeedbackCategory {
  bug,
  enhancement,
  question,
  performance,
  uiUx,
  documentation,
  other;

  // ---------------------------------------------------------------------------
  // Display
  // ---------------------------------------------------------------------------

  /// Human-readable label shown in the feedback sheet chip.
  String get displayLabel => switch (this) {
        FeedbackCategory.bug           => 'Bug Report',
        FeedbackCategory.enhancement   => 'Enhancement',
        FeedbackCategory.question      => 'Question',
        FeedbackCategory.performance   => 'Performance',
        FeedbackCategory.uiUx          => 'UI / UX',
        FeedbackCategory.documentation => 'Documentation',
        FeedbackCategory.other         => 'Other',
      };

  /// Emoji prefix shown alongside [displayLabel] in the chip.
  String get emoji => switch (this) {
        FeedbackCategory.bug           => '🐛',
        FeedbackCategory.enhancement   => '✨',
        FeedbackCategory.question      => '❓',
        FeedbackCategory.performance   => '⚡',
        FeedbackCategory.uiUx          => '🎨',
        FeedbackCategory.documentation => '📖',
        FeedbackCategory.other         => '💬',
      };

  // ---------------------------------------------------------------------------
  // GitHub
  // ---------------------------------------------------------------------------

  /// The label string applied to the created GitHub issue.
  ///
  /// Maps to GitHub's built-in default labels where available:
  /// `bug`, `enhancement`, `question`, `documentation`.
  ///
  /// Custom values (`performance`, `ui/ux`, `feedback`) are created
  /// automatically on first use by the GitHub Issues API.
  String get githubLabel => switch (this) {
        FeedbackCategory.bug           => 'bug',
        FeedbackCategory.enhancement   => 'enhancement',
        FeedbackCategory.question      => 'question',
        FeedbackCategory.performance   => 'performance',
        FeedbackCategory.uiUx          => 'ui/ux',
        FeedbackCategory.documentation => 'documentation',
        FeedbackCategory.other         => 'feedback',
      };
}
