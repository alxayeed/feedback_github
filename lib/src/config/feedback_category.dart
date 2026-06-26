/// A category that a user can assign to their feedback submission.
class FeedbackCategory {
  const FeedbackCategory({
    required this.label,
    this.emoji = '📝',
  });

  /// Human-readable label shown in the UI.
  final String label;

  /// Optional emoji prefix shown alongside the label.
  final String emoji;

  /// Default set of categories shipped with the package.
  ///
  /// Consumers may replace this list via [FeedbackConfig.categories].
  static const List<FeedbackCategory> defaults = [
    FeedbackCategory(label: 'Bug Report', emoji: '🐛'),
    FeedbackCategory(label: 'Feature Request', emoji: '✨'),
    FeedbackCategory(label: 'UI / UX', emoji: '🎨'),
    FeedbackCategory(label: 'Performance', emoji: '⚡'),
    FeedbackCategory(label: 'Other', emoji: '💬'),
  ];

  /// Returns `"emoji label"`, e.g. `"🐛 Bug Report"`.
  @override
  String toString() => '$emoji $label';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackCategory &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          emoji == other.emoji;

  @override
  int get hashCode => label.hashCode ^ emoji.hashCode;
}
