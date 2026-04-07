/// Test B36 — FontScaleProvider: persistenza e stato.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dydat/providers/font_scale_provider.dart';

void main() {
  group('FontScaleNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('default e FontScaleOption.normale (factor 1.0)', () {
      final notifier = FontScaleNotifier();
      expect(notifier.state, FontScaleOption.normale);
      expect(notifier.state.factor, 1.0);
    });

    test('setOption aggiorna lo stato a grande', () async {
      final notifier = FontScaleNotifier();
      await notifier.setOption(FontScaleOption.grande);
      expect(notifier.state, FontScaleOption.grande);
      expect(notifier.state.factor, 1.15);
    });

    test('setOption persiste in SharedPreferences', () async {
      final notifier = FontScaleNotifier();
      await notifier.setOption(FontScaleOption.moltoGrande);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('font_scale_factor'), 1.3);
    });

    test('carica valore precedentemente salvato', () async {
      // Salvo un valore prima di creare il notifier.
      SharedPreferences.setMockInitialValues({'font_scale_factor': 0.85});

      final notifier = FontScaleNotifier();
      // Attendo che _load() asincrono completi.
      await Future.delayed(Duration.zero);

      expect(notifier.state, FontScaleOption.piccolo);
      expect(notifier.state.factor, 0.85);
    });
  });

  group('FontScaleOption', () {
    test('ha 4 opzioni con label corrette', () {
      expect(FontScaleOption.values.length, 4);
      expect(FontScaleOption.piccolo.label, 'Piccolo');
      expect(FontScaleOption.normale.label, 'Normale');
      expect(FontScaleOption.grande.label, 'Grande');
      expect(FontScaleOption.moltoGrande.label, 'Molto grande');
    });
  });
}
