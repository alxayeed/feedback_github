import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

import '../config/feedback_category.dart';
import '../config/feedback_config.dart';

/// Returns a [FeedbackBuilder] configured from [config].
///
/// Pass the result directly to [BetterFeedback.feedbackBuilder]:
/// ```dart
/// BetterFeedback(
///   feedbackBuilder: buildCustomFeedbackSheet(config),
///   child: child,
/// )
/// ```
///
/// The builder closes over [config] so the sheet always has access to the
/// correct category list and backend without needing an [InheritedWidget]
/// look-up inside BetterFeedback's overlay.
FeedbackBuilder buildCustomFeedbackSheet(FeedbackConfig config) {
  return (context, onSubmit, scrollController) => _CustomFeedbackSheet(
        config: config,
        onSubmit: onSubmit,
        scrollController: scrollController,
      );
}

// ---------------------------------------------------------------------------
// Private sheet widget
// ---------------------------------------------------------------------------

class _CustomFeedbackSheet extends StatefulWidget {
  const _CustomFeedbackSheet({
    required this.config,
    required this.onSubmit,
    this.scrollController,
  });

  final FeedbackConfig config;

  /// BetterFeedback's submit callback — calling it captures the screenshot
  /// and forwards everything to the [GithubFeedback] widget's handler.
  final OnSubmit onSubmit;

  final ScrollController? scrollController;

  @override
  State<_CustomFeedbackSheet> createState() => _CustomFeedbackSheetState();
}

class _CustomFeedbackSheetState extends State<_CustomFeedbackSheet> {
  FeedbackCategory? _selected;
  final _textController = TextEditingController();
  bool _submitting = false;
  String? _error;

  bool get _canSubmit =>
      !_submitting &&
      _selected != null &&
      _textController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      // Calling onSubmit triggers BetterFeedback to capture the screenshot
      // and pass UserFeedback to the GithubFeedback widget's show() handler.
      await widget.onSubmit(
        _textController.text.trim(),
        extras: {'category': _selected!.label},
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cats = widget.config.categories;

    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          // ── Drag handle ────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ────────────────────────────────────────────────────
          Text(
            'Send Feedback',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Draw on the screenshot, pick a category, and describe the issue.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // ── Category chips ─────────────────────────────────────────────
          Text(
            'Category',
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cats.map((cat) {
              final isSelected = _selected == cat;
              return ChoiceChip(
                label: Text('${cat.emoji}  ${cat.label}'),
                selected: isSelected,
                onSelected: _submitting
                    ? null
                    : (_) => setState(() => _selected = cat),
                selectedColor: cs.primaryContainer,
                labelStyle: TextStyle(
                  color: isSelected
                      ? cs.onPrimaryContainer
                      : cs.onSurfaceVariant,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? cs.primary
                        : cs.outlineVariant,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Description field ──────────────────────────────────────────
          Text(
            'Description',
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            enabled: !_submitting,
            maxLines: 4,
            minLines: 3,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: "Describe what happened or what you'd like to see…",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
              filled: true,
              fillColor: cs.surfaceContainerLowest,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // ── Error banner ───────────────────────────────────────────────
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: cs.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: cs.error),
                    onPressed: () => setState(() => _error = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Submit button ──────────────────────────────────────────────
          FilledButton(
            onPressed: _canSubmit ? _submit : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _submitting
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: cs.onPrimary,
                    ),
                  )
                : const Text(
                    'Submit Feedback',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
