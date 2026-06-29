import 'package:feedback_github/src/feedback/feedback.dart';
import 'package:flutter/material.dart';

import '../config/feedback_category.dart';
import '../config/feedback_config.dart';
import '../state/feedback_scope.dart';

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
  DraggableScrollableController? _sheetController;
  bool _isFullscreen = false;

  bool get _canSubmit =>
      !_submitting &&
      _selected != null &&
      _textController.text.trim().isNotEmpty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final controller = BetterFeedback.of(context).sheetController;
      if (_sheetController != controller) {
        _sheetController?.removeListener(_onSheetSizeChanged);
        _sheetController = controller;
        _sheetController?.addListener(_onSheetSizeChanged);
        _onSheetSizeChanged();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _sheetController?.removeListener(_onSheetSizeChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onSheetSizeChanged() {
    if (_sheetController == null || !_sheetController!.isAttached) return;
    final size = _sheetController!.size;
    final isFullscreen = size > 0.6;
    if (isFullscreen != _isFullscreen) {
      setState(() {
        _isFullscreen = isFullscreen;
      });
    }
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
        // Store the enum name so FeedbackButton can reconstruct the value.
        extras: {'category': _selected!.name},
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _submitting = false;
        });
        if (_sheetController != null && _sheetController!.isAttached) {
          _sheetController!.animateTo(
            1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cats = widget.config.categories;
    final notifier = FeedbackScope.of(context);
    final screenshotBytes = notifier?.screenshotBytes;

    return Material(
      color: theme.cardColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(20, 12, 20, _isFullscreen ? 32 : 12),
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
          SizedBox(height: _isFullscreen ? 16 : 8),

          // ── Header Row ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Send Feedback',
                style:
                    (_isFullscreen
                            ? theme.textTheme.titleLarge
                            : theme.textTheme.titleMedium)
                        ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_isFullscreen) ...[
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.error,
                    foregroundColor: cs.onError,
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                    fixedSize: const Size(32, 32),
                  ),
                  onPressed: () {
                    BetterFeedback.of(context).hide();
                  },
                ),
              ] else ...[
                _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : FilledButton.icon(
                        onPressed: _canSubmit ? _submit : null,
                        icon: const Icon(Icons.send, size: 14),
                        label: const Text('Send'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
              ],
            ],
          ),
          if (_isFullscreen) ...[
            const SizedBox(height: 6),
            Text(
              'Draw on the screenshot, pick a category, and describe the issue.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: _isFullscreen ? 20 : 10),

          // ── Screenshot Preview (Only in Fullscreen - placed right after header) ───────────────────
          if (_isFullscreen && screenshotBytes != null) ...[
            SizedBox(
              height: 250,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(screenshotBytes, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Category chips ─────────────────────────────────────────────
          Text(
            'Category',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          SizedBox(height: _isFullscreen ? 8 : 4),
          _isFullscreen
              ? Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: cats.map((cat) {
                    final isSelected = _selected == cat;
                    return ChoiceChip(
                      label: Text(
                        '${cat.emoji}  ${cat.displayLabel}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: _submitting
                          ? null
                          : (_) => setState(() => _selected = cat),
                      backgroundColor: theme.cardColor,
                      selectedColor: cs.primaryContainer,
                      color: WidgetStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(WidgetState.selected))
                          return cs.primaryContainer;
                        return theme.cardColor;
                      }),
                      labelStyle: TextStyle(
                        color: theme.focusColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(
                          color: isSelected ? cs.primary : theme.focusColor,
                        ),
                      ),
                    );
                  }).toList(),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: cats.map((cat) {
                      final isSelected = _selected == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(
                            '${cat.emoji}  ${cat.displayLabel}',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: _submitting
                              ? null
                              : (_) => setState(() => _selected = cat),
                          backgroundColor: theme.cardColor,
                          selectedColor: cs.primaryContainer,
                          color: WidgetStateProperty.resolveWith<Color?>((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected))
                              return cs.primaryContainer;
                            return theme.cardColor;
                          }),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? cs.onPrimaryContainer
                                : theme.focusColor,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(
                              color: isSelected ? cs.primary : theme.focusColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
          SizedBox(height: _isFullscreen ? 20 : 10),

          // ── Description field ──────────────────────────────────────────
          Text(
            'Description',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          SizedBox(height: _isFullscreen ? 8 : 4),
          TextField(
            controller: _textController,
            enabled: !_submitting,
            maxLines: _isFullscreen ? 8 : 4,
            minLines: _isFullscreen ? 5 : 4,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: "Describe what happened or what you'd like to see…",
              hintStyle: TextStyle(
                color: cs.onSurfaceVariant.withValues(alpha: 0.55),
              ),
              contentPadding: _isFullscreen
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
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
                borderSide: BorderSide(color: theme.focusColor, width: 2),
              ),
              filled: true,
              fillColor: theme.focusColor,
            ),
            onChanged: (_) => setState(() {
              _isFullscreen = true;
            }),
            onTap: () {
              if (_sheetController != null && _sheetController!.isAttached) {
                _sheetController!.animateTo(
                  1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
          ),
          SizedBox(height: _isFullscreen ? 12 : 6),

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

          // ── Submit button (Only in Fullscreen) ────────────────────────
          if (_isFullscreen)
            FilledButton.icon(
              onPressed: _canSubmit ? _submit : null,
              icon: _submitting
                  ? const SizedBox.shrink()
                  : const Icon(Icons.send, size: 18),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: _submitting
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
