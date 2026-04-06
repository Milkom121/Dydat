import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sizer_extensions.dart';
import '../../providers/ripasso_provider.dart';
import '../../providers/session_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/custom_icon_widget.dart';
import '../studio_screen/widgets/session_history_widget.dart';

/// Schermata Home — Tab 0 della navigazione principale.
/// Mostra benvenuto, sezione ripasso FSRS, storico sessioni e CTA per studiare.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sessionProvider.notifier).loadSessionHistory();
      ref.read(ripassoProvider.notifier).carica();
    });
  }

  void _avviaStudio() {
    HapticFeedback.lightImpact();
    context.push(AppPaths.studio);
  }

  void _avviaRipasso() {
    HapticFeedback.lightImpact();
    context.push('${AppPaths.studio}?tipo=ripasso');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionState = ref.watch(sessionProvider);
    final ripassoTotale = ref.watch(ripassoProvider).totale;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Dydat', style: theme.textTheme.titleLarge),
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 1.0,
        shadowColor: theme.colorScheme.shadow,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 3.h),
                _buildBenvenuto(theme, sessionState),
                SizedBox(height: 3.h),
                _buildBottoneStudio(theme),
                if (ripassoTotale > 0) ...[
                  SizedBox(height: 2.h),
                  _buildSezioneRipasso(theme, ripassoTotale),
                ],
                SizedBox(height: 4.h),
                SessionHistoryWidget(
                  sessions: sessionState.sessionHistory,
                  isLoading: sessionState.isLoadingHistory,
                  onSessionTap: (sessioneId) {
                    context.go(AppPaths.recapSession(sessioneId));
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenvenuto(ThemeData theme, SessionScreenState sessionState) {
    final hasHistory = sessionState.sessionHistory.isNotEmpty;
    final hasActiveSession = sessionState.activeSession?.stato == 'attiva';

    String titolo;
    String sottotitolo;

    if (hasActiveSession) {
      titolo = 'Sessione in corso';
      sottotitolo = 'Continua da dove eri rimasto';
    } else if (hasHistory) {
      titolo = 'Bentornato!';
      sottotitolo = 'Pronto a continuare il tuo percorso?';
    } else {
      titolo = 'Benvenuto su Dydat!';
      sottotitolo = 'Inizia il tuo percorso di apprendimento';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titolo,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          sottotitolo,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBottoneStudio(ThemeData theme) {
    final hasActiveSession =
        ref.read(sessionProvider).activeSession?.stato == 'attiva';
    final label =
        hasActiveSession ? 'Riprendi la sessione' : 'Riprendi a studiare';

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _avviaStudio,
        icon: CustomIconWidget(
          iconName: 'school',
          color: theme.colorScheme.onPrimary,
          size: 20,
        ),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
        ),
      ),
    );
  }

  Widget _buildSezioneRipasso(ThemeData theme, int totale) {
    return Container(
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
                  '$totale ${totale == 1 ? 'nodo' : 'nodi'} da ripassare',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rinforza la tua memoria con una sessione breve',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          FilledButton.tonal(
            onPressed: _avviaRipasso,
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
