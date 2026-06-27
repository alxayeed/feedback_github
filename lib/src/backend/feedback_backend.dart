import 'dart:typed_data';

import '../config/feedback_category.dart';

/// Abstract interface for feedback submission backends.
///
/// Implement this to create a custom backend (e.g. Firestore, email, Slack).
///
/// Example:
/// ```dart
/// class MyBackend implements FeedbackBackend {
///   @override
///   Future<void> submit({
///     required FeedbackCategory category,
///     required String text,
///     Uint8List? screenshot,
///   }) async {
///     // your logic here — use category.displayLabel, category.githubLabel, etc.
///   }
/// }
/// ```
abstract interface class FeedbackBackend {
  /// Submits a single piece of user feedback.
  ///
  /// - [category]   — the selected [FeedbackCategory] enum value. Use
  ///   [FeedbackCategory.displayLabel] for display, [FeedbackCategory.githubLabel]
  ///   for GitHub labels, or [FeedbackCategory.emoji] for UI.
  /// - [text]       — the user's free-text description.
  /// - [screenshot] — raw PNG bytes captured by `BetterFeedback`; may be null.
  ///
  /// Implementations should throw on unrecoverable errors so that the UI
  /// can surface a meaningful message to the user.
  Future<void> submit({
    required FeedbackCategory category,
    required String text,
    Uint8List? screenshot,
  });
}
