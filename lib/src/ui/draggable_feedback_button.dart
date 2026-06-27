import 'package:flutter/material.dart';
import '../feedback/feedback.dart';
import '../state/feedback_scope.dart';
import 'feedback_button.dart';

/// A draggable floating button wrapper for [FeedbackButton].
///
/// Automatically handles drag gestures and bounds constraints to prevent
/// the button from going off-screen or overlapping system status/navigation bars.
/// Automatically hides itself when the feedback drawing overlay is active.
class DraggableFeedbackButton extends StatefulWidget {
  const DraggableFeedbackButton({super.key});

  @override
  State<DraggableFeedbackButton> createState() => _DraggableFeedbackButtonState();
}

class _DraggableFeedbackButtonState extends State<DraggableFeedbackButton> {
  Offset? _offset;

  @override
  Widget build(BuildContext context) {
    final notifier = FeedbackScope.of(context);
    if (notifier == null ||
        !notifier.config.enabled ||
        !notifier.config.showFloatingButton ||
        notifier.hasExplicitButton) {
      return const SizedBox.shrink();
    }

    final controller = BetterFeedback.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final mediaQuery = MediaQuery.of(context);
        final screenSize = mediaQuery.size;
        final topPadding = mediaQuery.padding.top;
        final bottomPadding = mediaQuery.padding.bottom;

        const double buttonSize = 56.0;
        const double minX = 16.0;
        final double maxX = screenSize.width - buttonSize - 16.0;
        final double minY = topPadding + 16.0;
        final double maxY = screenSize.height - buttonSize - bottomPadding - 16.0;

        // Resolve current position dynamically.
        // If _offset is null, default to bottom-right (maxX, maxY).
        final double targetX = _offset?.dx.clamp(minX, maxX) ?? maxX;
        final double targetY = _offset?.dy.clamp(minY, maxY) ?? maxY;

        return Positioned(
          left: targetX,
          top: targetY,
          child: Offstage(
            offstage: controller.isVisible,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (_) {}, // Claim gestures eagerly in the arena
              onPanUpdate: (details) {
                setState(() {
                  _offset = Offset(
                    (targetX + details.delta.dx).clamp(minX, maxX),
                    (targetY + details.delta.dy).clamp(minY, maxY),
                  );
                });
              },
              child: FeedbackButton(
                isDefaultFloatingButton: true,
                icon: notifier.config.icon ?? const Icon(Icons.feedback_outlined),
                backgroundColor: notifier.config.backgroundColor,
                foregroundColor: notifier.config.foregroundColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
