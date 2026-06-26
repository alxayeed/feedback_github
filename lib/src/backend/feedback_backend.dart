import 'dart:typed_data';

/// Abstract interface for feedback submission backends.
///
/// Implement this to create a custom backend (e.g. Firestore, email, Slack).
///
/// Example:
/// ```dart
/// class MyBackend implements FeedbackBackend {
///   @override
///   Future<void> submit({
///     required String category,
///     required String text,
///     Uint8List? screenshot,
///   }) async {
///     // your logic here
///   }
/// }
/// ```
abstract interface class FeedbackBackend {
  /// Submits a single piece of user feedback.
  ///
  /// - [category] — the selected [FeedbackCategory] label (e.g. "Bug Report").
  /// - [text]     — the user's free-text description.
  /// - [screenshot] — raw PNG bytes captured by `BetterFeedback`; may be null
  ///   if screenshot capture is unavailable.
  ///
  /// Implementations should throw on unrecoverable errors so that the UI
  /// can surface a meaningful message to the user.
  Future<void> submit({
    required String category,
    required String text,
    Uint8List? screenshot,
  });
}
