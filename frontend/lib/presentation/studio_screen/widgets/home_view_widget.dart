import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/sessione.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/custom_icon_widget.dart';
import './session_history_widget.dart';

/// Vista home della schermata studio: icona chat + testo + storico sessioni.
/// Se [ripassoTotale] > 0 mostra sezione "Da ripassare" con conteggio e bottone.
class HomeViewWidget extends StatelessWidget {
  final bool showingHome;
  final bool isActive;
  final List<SessioneListItem> sessionHistory;
  final bool isLoadingHistory;
  final int ripassoTotale;

  const HomeViewWidget({
    super.key,
    required this.showingHome,
    required this.isActive,
    required this.sessionHistory,
    required this.isLoadingHistory,
    this.ripassoTotale = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 4.h),
          CustomIconWidget(
            iconName: 'chat_bubble_outline',
            color: theme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            showingHome && isActive
                ? 'Hai una sessione attiva'
                : 'Inizia una sessione per chattare con il tutor',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (ripassoTotale > 0) ...[
            SizedBox(height: 3.h),
            _buildSezioneRipasso(context, theme),
          ],
          SizedBox(height: 4.h),
          SessionHistoryWidget(
            sessions: sessionHistory,
            isLoading: isLoadingHistory,
            onSessionTap: (sessioneId) {
              context.go(AppPaths.recapSession(sessioneId));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSezioneRipasso(BuildContext context, ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'replay',
            color: theme.colorScheme.onTertiaryContainer,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$ripassoTotale ${ripassoTotale == 1 ? 'nodo' : 'nodi'} da ripassare',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rinforza la tua memoria con una sessione breve',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          FilledButton.tonal(
            onPressed: () => context.go('/studio'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.tertiary,
              foregroundColor: theme.colorScheme.onTertiary,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            ),
            child: const Text('Vai'),
          ),
        ],
      ),
    );
  }
}
