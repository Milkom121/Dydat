import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Editor per la nota personale dell'utente con autosave debounced.
/// Chiama [onSave] dopo [debounceDuration] dall'ultima modifica.
class NotaUtenteEditor extends StatefulWidget {
  final String? initialText;
  final bool isSaving;
  final ValueChanged<String> onSave;
  final Duration debounceDuration;

  const NotaUtenteEditor({
    super.key,
    this.initialText,
    this.isSaving = false,
    required this.onSave,
    this.debounceDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<NotaUtenteEditor> createState() => _NotaUtenteEditorState();
}

class _NotaUtenteEditorState extends State<NotaUtenteEditor> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    // Salva eventuali modifiche pendenti prima di distruggere il widget
    if (_hasUnsavedChanges && _controller.text.isNotEmpty) {
      widget.onSave(_controller.text);
    }
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    setState(() => _hasUnsavedChanges = true);
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (value.trim().isNotEmpty) {
        widget.onSave(value.trim());
        if (mounted) {
          setState(() => _hasUnsavedChanges = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          children: [
            CustomIconWidget(
              iconName: 'edit_note',
              color: theme.colorScheme.primary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Le mie note',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Indicatore stato salvataggio
            _buildSaveIndicator(theme),
          ],
        ),
        SizedBox(height: 1.5.h),

        // Campo di testo
        TextField(
          controller: _controller,
          onChanged: _onTextChanged,
          maxLines: null,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Scrivi qui i tuoi appunti...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.all(3.w),
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSaveIndicator(ThemeData theme) {
    if (widget.isSaving) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 3.w,
            height: 3.w,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            'Salvo...',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (_hasUnsavedChanges) {
      return Text(
        'Modificato',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.tertiary,
        ),
      );
    }

    // Nessun indicatore se non ci sono modifiche
    return const SizedBox.shrink();
  }
}
