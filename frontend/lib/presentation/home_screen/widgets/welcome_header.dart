import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/sessione.dart';
import '../../../theme/surface_decorations.dart';
import '../../../utils/pluralize.dart' as pl;

/// Header di benvenuto contestuale.
/// Mostra un messaggio diverso in base a: primo accesso, ritorno normale,
/// assenza prolungata (>7 giorni), sessione attiva.
class WelcomeHeader extends StatelessWidget {
  final List<SessioneListItem> sessionHistory;
  final bool hasActiveSession;
  final String? lastNodeName;

  const WelcomeHeader({
    super.key,
    required this.sessionHistory,
    required this.hasActiveSession,
    this.lastNodeName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = _computeWelcomeInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          info.titolo,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          info.sottotitolo,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        // Messaggio contestuale: dove eravamo rimasti
        if (info.contestuale != null) ...[
          SizedBox(height: 1.5.h),
          _buildContestuale(theme, info.contestuale!),
        ],
        // Avviso assenza prolungata (tono caldo, nessun senso di colpa)
        if (info.assenzaMessaggio != null) ...[
          SizedBox(height: 1.5.h),
          _buildAssenzaCard(context, theme, info.assenzaMessaggio!),
        ],
      ],
    );
  }

  Widget _buildContestuale(ThemeData theme, String messaggio) {
    return Row(
      children: [
        Icon(
          Icons.bookmark_outline,
          size: 18,
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            messaggio,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssenzaCard(BuildContext context, ThemeData theme, String messaggio) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: DydatSurface.section(
        context,
        tintColor: theme.colorScheme.primary,
        borderRadius: 12.0,
        tintStrength: 0.1,
      ),
      child: Row(
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: 20,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              messaggio,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _WelcomeInfo _computeWelcomeInfo() {
    if (hasActiveSession) {
      return _WelcomeInfo(
        titolo: 'Sessione in corso',
        sottotitolo: 'Continua da dove eri rimasto',
      );
    }

    if (sessionHistory.isEmpty) {
      return _WelcomeInfo(
        titolo: 'Benvenuto su Dydat!',
        sottotitolo: 'Inizia il tuo percorso di apprendimento',
      );
    }

    // Calcola giorni dall'ultima sessione
    final lastSession = sessionHistory.first;
    final giorni = _giorniDaUltimaSessione(lastSession);

    String? contestuale;
    if (lastNodeName != null && lastNodeName!.isNotEmpty) {
      contestuale = 'Eravamo rimasti a "$lastNodeName"';
    }

    String? assenzaMessaggio;
    if (giorni != null && giorni > 7) {
      assenzaMessaggio = 'Bentornato! Sono passati ${pl.giorno(giorni)} '
          "dall'ultima sessione. Riprendere è facile: "
          'anche solo 5 minuti fanno la differenza.';
    }

    return _WelcomeInfo(
      titolo: 'Bentornato!',
      sottotitolo: giorni != null && giorni > 7
          ? 'Bello rivederti!'
          : 'Pronto a continuare il tuo percorso?',
      contestuale: contestuale,
      assenzaMessaggio: assenzaMessaggio,
    );
  }

  int? _giorniDaUltimaSessione(SessioneListItem session) {
    final dateStr = session.completedAt ?? session.createdAt;
    if (dateStr == null) return null;
    try {
      final date = DateTime.parse(dateStr);
      return DateTime.now().difference(date).inDays;
    } catch (_) {
      return null;
    }
  }
}

class _WelcomeInfo {
  final String titolo;
  final String sottotitolo;
  final String? contestuale;
  final String? assenzaMessaggio;

  const _WelcomeInfo({
    required this.titolo,
    required this.sottotitolo,
    this.contestuale,
    this.assenzaMessaggio,
  });
}
