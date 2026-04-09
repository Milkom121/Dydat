import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/sizer_extensions.dart';

/// Campo di input testuale riutilizzabile con pulsante microfono.
///
/// Il pulsante microfono è disabilitato come placeholder — la funzionalità
/// audio verrà implementata in B39.7.2+.
/// Usato in: onboarding, sessione studio, ricerca "I miei studi".
class VoiceInputField extends StatefulWidget {
  /// Testo placeholder nel campo input
  final String hintText;

  /// Callback quando l'utente invia il testo
  final ValueChanged<String> onSubmit;

  /// Se true, il campo è disabilitato (es. durante streaming tutor)
  final bool enabled;

  /// Numero massimo di righe (null = illimitato)
  final int? maxLines;

  /// Controller esterno opzionale (se null, ne crea uno interno)
  final TextEditingController? controller;

  const VoiceInputField({
    super.key,
    this.hintText = 'Scrivi qui...',
    required this.onSubmit,
    this.enabled = true,
    this.maxLines,
    this.controller,
  });

  @override
  State<VoiceInputField> createState() => VoiceInputFieldState();
}

/// Stato pubblico per consentire accesso al controller dall'esterno
/// (es. per popolare il testo trascritto in B39.7.5).
class VoiceInputFieldState extends State<VoiceInputField> {
  late final TextEditingController _controller;
  bool _ownsController = false;

  TextEditingController get controller => _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Campo di testo
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
            ),
            maxLines: widget.maxLines,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _handleSubmit(),
          ),
        ),
        SizedBox(width: 2.w),
        // Pulsante microfono (placeholder disabilitato)
        Semantics(
          label: 'Microfono — non ancora disponibile',
          child: IconButton(
            onPressed: null, // Disabilitato — audio in B39.7.2+
            icon: Icon(
              Icons.mic,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            tooltip: 'Voce — prossimamente',
          ),
        ),
        // Pulsante invio
        IconButton(
          onPressed: widget.enabled ? _handleSubmit : null,
          icon: Icon(
            Icons.send_rounded,
            color: widget.enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          tooltip: 'Invia',
        ),
      ],
    );
  }
}
