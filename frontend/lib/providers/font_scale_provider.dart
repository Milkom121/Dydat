import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opzioni discrete per la scala dei font in-app.
enum FontScaleOption {
  piccolo(0.85, 'Piccolo'),
  normale(1.0, 'Normale'),
  grande(1.15, 'Grande'),
  moltoGrande(1.3, 'Molto grande');

  final double factor;
  final String label;
  const FontScaleOption(this.factor, this.label);
}

class FontScaleNotifier extends StateNotifier<FontScaleOption> {
  static const _key = 'font_scale_factor';

  FontScaleNotifier() : super(FontScaleOption.normale) {
    _load();
  }

  /// Carica il valore salvato da SharedPreferences.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getDouble(_key);
    if (value != null) {
      state = FontScaleOption.values.firstWhere(
        (e) => e.factor == value,
        orElse: () => FontScaleOption.normale,
      );
    }
  }

  /// Imposta e persiste l'opzione scelta.
  Future<void> setOption(FontScaleOption option) async {
    state = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, option.factor);
  }
}

final fontScaleProvider =
    StateNotifierProvider<FontScaleNotifier, FontScaleOption>((ref) {
  return FontScaleNotifier();
});
