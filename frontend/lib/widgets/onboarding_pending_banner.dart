import 'package:flutter/material.dart';

import '../core/sizer_extensions.dart';
import '../theme/surface_decorations.dart';

/// Stato dell'onboarding dell'utente, usato per determinare
/// il messaggio e la CTA del banner.
enum OnboardingBannerStato {
  /// Utente appena registrato, non ha mai iniziato l'onboarding.
  nonIniziato,

  /// Utente ha iniziato ma ha saltato o interrotto l'onboarding.
  inCorso,
}

/// Banner persistente (non dismissibile) che invita l'utente
/// a iniziare o riprendere l'onboarding.
///
/// Mostra un messaggio caldo e una CTA contestuale.
/// Non viene renderizzato se l'onboarding è completato
/// (responsabilità del genitore non mostrarlo).
class OnboardingPendingBanner extends StatelessWidget {
  final OnboardingBannerStato stato;
  final VoidCallback onTap;

  const OnboardingPendingBanner({
    super.key,
    required this.stato,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Semantics(
      label: stato == OnboardingBannerStato.nonIniziato
          ? 'Inizia la configurazione del tuo percorso'
          : 'Riprendi la configurazione del tuo percorso',
      button: true,
      child: Container(
        padding: EdgeInsets.all(3.5.w),
        decoration: DydatSurface.glowCard(
          context,
          glowColor: cs.primary,
          glowIntensity: 0.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.waving_hand_rounded,
                    color: cs.primary,
                    size: 22,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titolo,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        _sottotitolo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 1.2.h),
                ),
                child: Text(_ctaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _titolo {
    switch (stato) {
      case OnboardingBannerStato.nonIniziato:
        return 'Raccontami di te!';
      case OnboardingBannerStato.inCorso:
        return 'Riprendiamo da dove eravamo';
    }
  }

  String get _sottotitolo {
    switch (stato) {
      case OnboardingBannerStato.nonIniziato:
        return 'Una breve chiacchierata per costruire il tuo percorso su misura.';
      case OnboardingBannerStato.inCorso:
        return 'Mancano pochi passi per completare il tuo profilo.';
    }
  }

  String get _ctaLabel {
    switch (stato) {
      case OnboardingBannerStato.nonIniziato:
        return 'Inizia';
      case OnboardingBannerStato.inCorso:
        return 'Riprendi';
    }
  }
}
