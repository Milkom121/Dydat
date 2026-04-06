import 'package:flutter/material.dart';

/// Decorazioni di superficie per il mood "studio notturno illuminato".
/// Tutte le decorazioni usano Theme.of(context) — zero colori hardcoded.
class DydatSurface {
  DydatSurface._();

  // ---------------------------------------------------------------------------
  // Gradienti di sfondo per Scaffold
  // ---------------------------------------------------------------------------

  /// Gradiente radiale per sfondo pagina: centro leggermente piu chiaro.
  /// Usare come decoration di un Container che wrappa il body del Scaffold.
  static BoxDecoration backgroundGradient(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topCenter,
        radius: 1.8,
        colors: [
          Color.lerp(scaffoldColor, cs.surface, 0.15)!,
          scaffoldColor,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card con gradiente sottile + bordo glow
  // ---------------------------------------------------------------------------

  /// Card standard con gradiente verticale sottile e ombra di profondita.
  static BoxDecoration card(
    BuildContext context, {
    double borderRadius = 16.0,
    int depthLevel = 1,
  }) {
    final cs = Theme.of(context).colorScheme;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(cs.surface, cs.primary, 0.03)!,
          cs.surface,
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: cs.outline.withValues(alpha: 0.12),
        width: 1.0,
      ),
      boxShadow: _depthShadows(cs, depthLevel),
    );
  }

  /// Card con bordo glow ambra — per card evidenziate / CTA.
  static BoxDecoration glowCard(
    BuildContext context, {
    double borderRadius = 16.0,
    Color? glowColor,
    double glowIntensity = 0.25,
    int depthLevel = 1,
  }) {
    final cs = Theme.of(context).colorScheme;
    final glow = glowColor ?? cs.primary;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(cs.surface, glow, 0.05)!,
          cs.surface,
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: glow.withValues(alpha: 0.3),
        width: 1.0,
      ),
      boxShadow: [
        // Glow esterno
        BoxShadow(
          color: glow.withValues(alpha: glowIntensity * 0.4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
        ..._depthShadows(cs, depthLevel),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Sezione con sfondo gradiente (es. ripasso, statistiche)
  // ---------------------------------------------------------------------------

  /// Contenitore sezione con gradiente lineare sottile.
  static BoxDecoration section(
    BuildContext context, {
    Color? tintColor,
    double borderRadius = 16.0,
    double tintStrength = 0.08,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tint = tintColor ?? cs.primary;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(cs.surface, tint, tintStrength)!,
          Color.lerp(cs.surface, tint, tintStrength * 0.3)!,
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: tint.withValues(alpha: 0.15),
        width: 1.0,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Nodo cerchio con glow (per mappa percorso)
  // ---------------------------------------------------------------------------

  /// Decorazione cerchio con glow per nodo attivo/in-progress.
  static BoxDecoration glowCircle(
    BuildContext context, {
    required Color nodeColor,
    double glowIntensity = 0.35,
    double borderWidth = 2.5,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: nodeColor.withValues(alpha: 0.15),
      border: Border.all(
        color: nodeColor,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: nodeColor.withValues(alpha: glowIntensity),
          blurRadius: 10,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: nodeColor.withValues(alpha: glowIntensity * 0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Ombre realistiche a livelli di profondita
  // ---------------------------------------------------------------------------

  /// Ombre realistiche con 3 livelli di profondita.
  /// Level 0: nessuna ombra, 1: leggera, 2: media, 3: pronunciata.
  static List<BoxShadow> _depthShadows(ColorScheme cs, int level) {
    if (level <= 0) return const [];

    // Ombra principale: scura, stretta
    // Ombra ambientale: diffusa, leggera
    final double mainBlur = 4.0 * level;
    final double mainOffset = 2.0 * level;
    final double ambientBlur = 8.0 * level;
    final double mainAlpha = 0.12 + (level * 0.06);
    final double ambientAlpha = 0.06 + (level * 0.03);

    return [
      BoxShadow(
        color: cs.shadow.withValues(alpha: mainAlpha.clamp(0.0, 1.0)),
        blurRadius: mainBlur,
        offset: Offset(0, mainOffset),
      ),
      BoxShadow(
        color: cs.shadow.withValues(alpha: ambientAlpha.clamp(0.0, 1.0)),
        blurRadius: ambientBlur,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Accesso pubblico alle ombre di profondita.
  static List<BoxShadow> depthShadows(BuildContext context, {int level = 1}) {
    return _depthShadows(Theme.of(context).colorScheme, level);
  }
}
