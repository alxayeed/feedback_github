import 'package:feedback_github/src/feedback/feedback.dart';
import 'package:flutter/material.dart';

import '../config/feedback_category.dart';
import '../state/feedback_notifier.dart';
import '../state/feedback_scope.dart';

/// The visual variant of the [FeedbackButton].
enum FeedbackButtonVariant {
  /// A small button showing only the icon.
  small,

  /// A larger button showing the icon and text label.
  big,
}

/// A pre-built [FloatingActionButton] that launches the feedback flow.
///
/// Drop this into your [Scaffold.floatingActionButton] — no other wiring
/// needed as long as your app is wrapped with [GithubFeedback]:
///
/// ```dart
/// Scaffold(
///   floatingActionButton: FeedbackButton(),
///   body: ...,
/// )
/// ```
///
/// The button is invisible (`SizedBox.shrink`) when
/// [FeedbackConfig.enabled] is `false`, so it is safe to leave in the
/// widget tree in production builds.
///
/// **Customisation** — swap the icon or label as needed:
/// ```dart
/// FeedbackButton(
///   variant: FeedbackButtonVariant.big,
///   icon:  Icon(Icons.bug_report_outlined),
///   label: Text('Report a bug'),
/// )
/// ```
class FeedbackButton extends StatefulWidget {
  const FeedbackButton({
    super.key,
    this.icon = const Icon(Icons.feedback_outlined),
    this.label = const Text('Feedback'),
    this.variant = FeedbackButtonVariant.small,
    this.isDefaultFloatingButton = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Icon shown on the FAB. Defaults to `Icons.feedback_outlined`.
  final Widget icon;

  /// Label shown on the extended FAB (only in [FeedbackButtonVariant.big] variant).
  /// Defaults to `"Feedback"`.
  final Widget label;

  /// The visual variant of the button. Defaults to [FeedbackButtonVariant.small].
  final FeedbackButtonVariant variant;

  /// Internal flag to indicate if this is the default floating button.
  final bool isDefaultFloatingButton;

  /// Custom background color of the button.
  final Color? backgroundColor;

  /// Custom foreground color (icon/text color) of the button.
  final Color? foregroundColor;

  @override
  State<FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<FeedbackButton> {
  FeedbackNotifier? _notifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newNotifier = FeedbackScope.of(context);
    if (_notifier != newNotifier) {
      if (!widget.isDefaultFloatingButton) {
        final oldNotifier = _notifier;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          oldNotifier?.unregisterExplicitButton();
          newNotifier?.registerExplicitButton();
        });
      }
      _notifier = newNotifier;
    }
  }

  @override
  void dispose() {
    if (!widget.isDefaultFloatingButton) {
      final notifierToUnregister = _notifier;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifierToUnregister?.unregisterExplicitButton();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If GithubFeedback is disabled, notifier will be null because the scope is not in the tree.
    final notifier = _notifier;

    if (notifier == null || !notifier.config.enabled) {
      return const SizedBox.shrink();
    }

    if (widget.variant == FeedbackButtonVariant.big) {
      return FloatingActionButton.extended(
        // Explicit heroTag prevents Hero conflicts when consumers also have FABs.
        heroTag: 'feedback_github_fab',
        onPressed: () => _showFeedback(context),
        icon: widget.icon,
        label: widget.label,
        backgroundColor: widget.backgroundColor,
        foregroundColor: widget.foregroundColor,
      );
    } else {
      return FloatingActionButton(
        // Explicit heroTag prevents Hero conflicts when consumers also have FABs.
        heroTag: 'feedback_github_fab',
        onPressed: () => _showFeedback(context),
        backgroundColor: widget.backgroundColor,
        foregroundColor: widget.foregroundColor,
        child: widget.icon,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _showFeedback(BuildContext context) async {
    // Use read() inside a callback — no rebuild subscription needed.
    final notifier = FeedbackScope.read(context);
    final config = notifier?.config;
    if (config == null) return;

    // Capture screenshot of the app widget tree before showing the drawing overlay
    await notifier?.captureScreenshot();

    // ignore: use_build_context_synchronously
    BetterFeedback.of(context).show((UserFeedback feedback) async {
      // Reconstruct the enum value from its name stored by the sheet.
      final categoryName = feedback.extra?['category'] as String?;
      final category = FeedbackCategory.values.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => config.categories.first,
      );

      try {
        await config.backend.submit(
          category: category,
          text: feedback.text,
          screenshot: feedback.screenshot,
        );
        if (!context.mounted) return;
        final messenger = _findScaffoldMessenger(context, notifier);
        if (messenger != null) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Feedback submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint('Feedback submission error: $e');
        debugPrint(stackTrace.toString());
        if (!context.mounted) return;
        final messenger = _findScaffoldMessenger(context, notifier);
        if (messenger != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Expanded(
                    child: Text('Failed to submit feedback: $e'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      messenger.hideCurrentSnackBar();
                    },
                  ),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        rethrow;
      }
    });
  }

  ScaffoldMessengerState? _findScaffoldMessenger(BuildContext context, FeedbackNotifier? notifier) {
    try {
      return ScaffoldMessenger.of(context);
    } catch (_) {}

    final repaintContext = notifier?.repaintBoundaryKey.currentContext;
    if (repaintContext is Element) {
      ScaffoldMessengerState? state;
      void visitor(Element element) {
        if (state != null) return;
        if (element is StatefulElement && element.state is ScaffoldMessengerState) {
          state = element.state as ScaffoldMessengerState;
          return;
        }
        element.visitChildren(visitor);
      }
      repaintContext.visitChildren(visitor);
      return state;
    }
    return null;
  }
}
