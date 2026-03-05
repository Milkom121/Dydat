import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/sessione.dart';
import '../../../widgets/custom_icon_widget.dart';

class SessionHistoryWidget extends StatelessWidget {
  final List<SessioneListItem> sessions;
  final bool isLoading;
  final ValueChanged<String> onSessionTap;

  const SessionHistoryWidget({
    super.key,
    required this.sessions,
    required this.isLoading,
    required this.onSessionTap,
  });

  String _formatNodeName(String? name) {
    if (name == null) return 'Sessione di studio';
    if (!name.contains('_')) return name;
    final parts = name.split('_');
    int start = 0;
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty &&
          parts[i] == parts[i].toLowerCase() &&
          !parts[i].startsWith('mat')) {
        start = i;
        break;
      }
    }
    if (start == 0 && parts.length > 1) start = parts.length > 3 ? 3 : 1;
    final formatted = parts.sublist(start).join(' ');
    return formatted.isNotEmpty
        ? formatted[0].toUpperCase() + formatted.substring(1)
        : name;
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} min fa';
      }
      if (diff.inHours < 24) {
        return '${diff.inHours}h fa';
      }
      if (diff.inDays == 1) {
        return 'Ieri';
      }
      if (diff.inDays < 7) {
        return '${diff.inDays}g fa';
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return '--';
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}min' : '${h}h';
  }

  String _statusLabel(String stato) {
    return switch (stato) {
      'completata' => 'Completata',
      'sospesa' => 'Sospesa',
      'attiva' => 'In corso',
      _ => stato,
    };
  }

  IconData _statusIcon(String stato) {
    return switch (stato) {
      'completata' => Icons.check_circle,
      'sospesa' => Icons.pause_circle,
      'attiva' => Icons.play_circle,
      _ => Icons.circle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
          child: Text(
            'Sessioni recenti',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...sessions.map(
          (session) => _SessionCard(
            session: session,
            theme: theme,
            formatNodeName: _formatNodeName,
            formatDate: _formatDate,
            formatDuration: _formatDuration,
            statusLabel: _statusLabel,
            statusIcon: _statusIcon,
            onTap: () {
              HapticFeedback.lightImpact();
              onSessionTap(session.id);
            },
          ),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessioneListItem session;
  final ThemeData theme;
  final String Function(String?) formatNodeName;
  final String Function(String?) formatDate;
  final String Function(int?) formatDuration;
  final String Function(String) statusLabel;
  final IconData Function(String) statusIcon;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.theme,
    required this.formatNodeName,
    required this.formatDate,
    required this.formatDuration,
    required this.statusLabel,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nodeName =
        formatNodeName(session.nodoFocaleNome ?? session.nodoFocaleId);
    final dateStr = formatDate(session.createdAt);
    final durationStr = formatDuration(session.durataEffettivaMin);
    final nodiCount = session.nodiLavorati?.length ?? 0;

    final statusColor = switch (session.stato) {
      'completata' => theme.colorScheme.secondary,
      'sospesa' => theme.colorScheme.tertiary,
      _ => theme.colorScheme.primary,
    };

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                // Status icon
                Icon(
                  statusIcon(session.stato),
                  color: statusColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nodeName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          if (dateStr.isNotEmpty) ...[
                            CustomIconWidget(
                              iconName: 'schedule',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              dateStr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(width: 3.w),
                          ],
                          CustomIconWidget(
                            iconName: 'timer',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            durationStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (nodiCount > 0) ...[
                            SizedBox(width: 3.w),
                            CustomIconWidget(
                              iconName: 'route',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '$nodiCount nodi',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
