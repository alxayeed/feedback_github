/// A reusable Flutter package for sending in-app feedback
/// directly to GitHub Issues with screenshot capture.
library;

// ── Root widget ──────────────────────────────────────────────────────────────
export 'src/github_feedback.dart';

// ── Config ───────────────────────────────────────────────────────────────────
export 'src/config/feedback_config.dart';
export 'src/config/feedback_category.dart';

// ── Backend ──────────────────────────────────────────────────────────────────
export 'src/backend/feedback_backend.dart';
export 'src/backend/github_feedback_backend.dart';

// ── State (advanced use) ─────────────────────────────────────────────────────
export 'src/state/feedback_notifier.dart';
export 'src/state/feedback_scope.dart';

// ── UI widgets ───────────────────────────────────────────────────────────────
export 'src/ui/feedback_button.dart';
export 'src/ui/draggable_feedback_button.dart';
