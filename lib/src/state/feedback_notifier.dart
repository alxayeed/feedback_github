import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../config/feedback_category.dart';
import '../config/feedback_config.dart';

/// Holds all mutable state for a single feedback submission.
///
/// Consumed via [FeedbackScope.of(context)] inside the widget tree.
class FeedbackNotifier extends ChangeNotifier {
  FeedbackNotifier({required this.config});

  /// The resolved [FeedbackConfig] provided by [GithubFeedback].
  final FeedbackConfig config;

  /// GlobalKey used to find the RepaintBoundary for screenshotting.
  final GlobalKey repaintBoundaryKey = GlobalKey();

  // ---------------------------------------------------------------------------
  // State fields
  // ---------------------------------------------------------------------------

  bool _isSubmitting = false;
  String? _error;
  FeedbackCategory? _selectedCategory;
  String _text = '';
  Uint8List? _screenshotBytes;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Whether a submission is currently in flight.
  bool get isSubmitting => _isSubmitting;

  /// The last error message, or `null` if no error has occurred.
  String? get error => _error;

  /// The currently selected [FeedbackCategory], or `null` if none chosen yet.
  FeedbackCategory? get selectedCategory => _selectedCategory;

  /// The current free-text feedback entered by the user.
  String get text => _text;

  /// The screenshot bytes captured when the feedback flow is initiated.
  Uint8List? get screenshotBytes => _screenshotBytes;

  /// Whether all required fields are filled and submission is not in progress.
  bool get canSubmit =>
      !_isSubmitting &&
      _selectedCategory != null &&
      _text.trim().isNotEmpty;

  // ---------------------------------------------------------------------------
  // Mutators
  // ---------------------------------------------------------------------------

  /// Selects [category] and clears any existing error.
  void selectCategory(FeedbackCategory category) {
    _selectedCategory = category;
    _error = null;
    notifyListeners();
  }

  /// Updates the free-text field and clears any existing error.
  void updateText(String value) {
    _text = value;
    _error = null;
    notifyListeners();
  }

  /// Captures a screenshot of the app widget tree.
  Future<void> captureScreenshot() async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        _screenshotBytes = byteData?.buffer.asUint8List();
        notifyListeners();
      }
    } catch (e, st) {
      debugPrint('[FeedbackNotifier] captureScreenshot error: $e\n$st');
    }
  }

  /// Resets all fields back to their initial values.
  void reset() {
    _isSubmitting = false;
    _error = null;
    _selectedCategory = null;
    _text = '';
    _screenshotBytes = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Submission
  // ---------------------------------------------------------------------------

  /// Submits the current feedback via [FeedbackConfig.backend].
  ///
  /// [screenshot] — raw PNG bytes from BetterFeedback; may be `null`.
  ///
  /// On success, calls [reset]. On failure, exposes the error message via
  /// [error] and stops the loading state so the user can retry or dismiss.
  Future<void> submit(Uint8List? screenshot) async {
    if (!canSubmit) return;

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await config.backend.submit(
        category: _selectedCategory!,
        text: _text.trim(),
        screenshot: screenshot,
      );
      reset();
    } catch (e, st) {
      debugPrint('[FeedbackNotifier] submit error: $e\n$st');
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
