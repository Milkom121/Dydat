import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/font_scale_provider.dart';

/// Ritorna il fontSize scalato per i widget Math.tex.
/// flutter_math_fork non rispetta il TextScaler nativo di MediaQuery,
/// quindi applichiamo manualmente il fattore di scala del provider.
double scaledLatexFontSize(WidgetRef ref, double baseFontSize) {
  final scale = ref.watch(fontScaleProvider).factor;
  return baseFontSize * scale;
}
