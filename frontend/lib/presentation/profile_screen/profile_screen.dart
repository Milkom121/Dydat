import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sizer_extensions.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userProvider.notifier).loadProfile();
      ref.read(statsProvider.notifier).load();
      ref.read(achievementProvider.notifier).load();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(userProvider.notifier).loadProfile(),
      ref.read(statsProvider.notifier).load(),
      ref.read(achievementProvider.notifier).load(),
    ]);
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text('Esci', style: theme.textTheme.titleLarge),
          content: Text(
            'Sei sicuro di voler uscire dal tuo account?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Annulla',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: Text(
                'Esci',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userState = ref.watch(userProvider);
    final statsState = ref.watch(statsProvider);
    final achievementState = ref.watch(achievementProvider);
    final themeMode = ref.watch(themeProvider);

    final isLoading = userState.isLoading && userState.profile == null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'Profilo'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
                children: [
                  _buildIdentityCard(theme, userState),
                  SizedBox(height: 2.h),
                  _buildStatsCard(theme, statsState),
                  SizedBox(height: 2.h),
                  _buildAchievementSection(theme, achievementState),
                  SizedBox(height: 2.h),
                  _buildThemeCard(theme, themeMode),
                  SizedBox(height: 2.h),
                  _buildLogoutButton(theme),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
    );
  }

  Widget _buildIdentityCard(ThemeData theme, UserState userState) {
    final user = userState.profile;
    final initials = (user?.nome != null && user!.nome!.isNotEmpty)
        ? user.nome![0].toUpperCase()
        : '?';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              initials,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.nome ?? 'Utente',
                  style: theme.textTheme.titleLarge,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  user?.email ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (user?.materieAttive != null &&
                    user!.materieAttive!.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    user.materieAttive!
                        .map((m) => m[0].toUpperCase() + m.substring(1))
                        .join(', '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme, StatsState statsState) {
    final stats = statsState.stats;

    if (statsState.isLoading && stats == null) {
      return _buildCardShell(
        theme,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (statsState.error != null && stats == null) {
      return _buildCardShell(
        theme,
        child: Text(
          statsState.error!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    return _buildCardShell(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistiche', style: theme.textTheme.titleMedium),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              _buildStatItem(
                theme,
                icon: 'local_fire_department',
                value: '${stats?.streak ?? 0}',
                label: 'Streak',
              ),
              _buildStatItem(
                theme,
                icon: 'check_circle',
                value: '${stats?.nodiCompletati ?? 0}',
                label: 'Nodi',
              ),
              _buildStatItem(
                theme,
                icon: 'school',
                value: '${stats?.sessioniCompletate ?? 0}',
                label: 'Sessioni',
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          SizedBox(height: 1.h),
          Text(
            'Questa settimana',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              _buildMiniStat(
                theme,
                '${stats?.settimana.minutiStudio ?? 0} min',
                'Studio',
              ),
              _buildMiniStat(
                theme,
                '${stats?.settimana.eserciziSvolti ?? 0}',
                'Esercizi',
              ),
              _buildMiniStat(
                theme,
                '${stats?.settimana.giorniAttivi ?? 0}',
                'Giorni',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardShell(ThemeData theme, {required Widget child}) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }

  Widget _buildStatItem(
    ThemeData theme, {
    required String icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(ThemeData theme, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementSection(
    ThemeData theme,
    AchievementState achievementState,
  ) {
    if (achievementState.isLoading &&
        achievementState.unlocked.isEmpty &&
        achievementState.next.isEmpty) {
      return _buildCardShell(
        theme,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return _buildCardShell(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Achievement', style: theme.textTheme.titleMedium),
          SizedBox(height: 1.5.h),

          if (achievementState.unlocked.isEmpty &&
              achievementState.next.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Center(
                child: Text(
                  'Nessun achievement ancora',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

          ...achievementState.unlocked.map((a) => Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: _achievementIcon(a.tipo),
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.nome, style: theme.textTheme.bodyMedium),
                          if (a.descrizione != null)
                            Text(
                              a.descrizione!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                  ],
                ),
              )),

          if (achievementState.next.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Text(
              'Prossimi',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            ...achievementState.next.take(3).map((a) => Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: _achievementIcon(a.tipo),
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.nome, style: theme.textTheme.bodyMedium),
                            SizedBox(height: 0.5.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: a.progresso.richiesto > 0
                                    ? a.progresso.corrente /
                                        a.progresso.richiesto
                                    : 0,
                                backgroundColor: theme.colorScheme.outline
                                    .withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '${a.progresso.corrente}/${a.progresso.richiesto}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  String _achievementIcon(String tipo) {
    switch (tipo) {
      case 'sigillo':
        return 'verified';
      case 'medaglia':
        return 'military_tech';
      case 'costellazione':
        return 'star';
      default:
        return 'emoji_events';
    }
  }

  Widget _buildThemeCard(ThemeData theme, ThemeMode themeMode) {
    return _buildCardShell(
      theme,
      child: Row(
        children: [
          CustomIconWidget(
            iconName:
                themeMode == ThemeMode.dark ? 'dark_mode' : 'light_mode',
            color: theme.colorScheme.primary,
            size: 22,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text('Tema', style: theme.textTheme.titleMedium),
          ),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode, size: 18),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode, size: 18),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.settings_brightness, size: 18),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (selected) {
              HapticFeedback.lightImpact();
              ref
                  .read(themeProvider.notifier)
                  .setThemeMode(selected.first);
            },
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        icon: CustomIconWidget(
          iconName: 'logout',
          color: theme.colorScheme.error,
          size: 20,
        ),
        label: Text(
          'Esci',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.error),
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
