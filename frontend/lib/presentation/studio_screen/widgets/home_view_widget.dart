import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/sessione.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/custom_icon_widget.dart';
import './session_history_widget.dart';

/// Vista home della schermata studio: icona chat + testo + storico sessioni.
class HomeViewWidget extends StatelessWidget {
  final bool showingHome;
  final bool isActive;
  final List<SessioneListItem> sessionHistory;
  final bool isLoadingHistory;

  const HomeViewWidget({
    super.key,
    required this.showingHome,
    required this.isActive,
    required this.sessionHistory,
    required this.isLoadingHistory,
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
}
