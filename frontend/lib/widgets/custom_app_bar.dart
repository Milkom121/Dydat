import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom app bar for Dydat AI tutoring app.
/// Implements the Conversational Minimalism design style with warm academic palette.
///
/// Features:
/// - Minimal elevation for subtle depth
/// - Contextual actions based on screen
/// - Consistent typography using Plus Jakarta Sans
/// - Support for both light and dark themes
/// - Optional leading and action widgets
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Leading widget (typically back button or menu icon)
  final Widget? leading;

  /// Action widgets displayed on the right side
  final List<Widget>? actions;

  /// Whether to show a back button automatically
  final bool automaticallyImplyLeading;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom background color (overrides theme)
  final Color? backgroundColor;

  /// Custom foreground color (overrides theme)
  final Color? foregroundColor;

  /// Elevation of the app bar
  final double elevation;

  /// Bottom widget (typically TabBar)
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 1.0,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: subtitle != null
          ? Column(
              crossAxisAlignment: centerTitle
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: foregroundColor ?? colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: (foregroundColor ?? colorScheme.onSurface)
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: foregroundColor ?? colorScheme.onSurface,
              ),
            ),
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation,
      shadowColor: colorScheme.shadow,
      systemOverlayStyle: theme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

/// Variant of CustomAppBar for Studio screen with session controls
class CustomStudioAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Current session timer display
  final String? sessionTime;

  /// Callback when pause button is pressed
  final VoidCallback? onPause;

  /// Callback when settings button is pressed
  final VoidCallback? onSettings;

  /// Whether the session is currently active
  final bool isSessionActive;

  const CustomStudioAppBar({
    super.key,
    this.sessionTime,
    this.onPause,
    this.onSettings,
    this.isSessionActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school, size: 24, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text('Studio', style: theme.textTheme.titleLarge),
          if (sessionTime != null && isSessionActive) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sessionTime!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (isSessionActive && onPause != null)
          IconButton(
            icon: const Icon(Icons.pause_circle_outline),
            onPressed: () {
              HapticFeedback.lightImpact();
              onPause!();
            },
            tooltip: 'Pausa sessione',
          ),
        if (onSettings != null)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              onSettings!();
            },
            tooltip: 'Impostazioni',
          ),
        const SizedBox(width: 8),
      ],
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 1.0,
      shadowColor: colorScheme.shadow,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Variant of CustomAppBar for Percorso screen with progress indicator
class CustomPercorsoAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Overall learning progress (0.0 to 1.0)
  final double progress;

  /// Callback when filter button is pressed
  final VoidCallback? onFilter;

  /// Number of active filters
  final int activeFilters;

  const CustomPercorsoAppBar({
    super.key,
    required this.progress,
    this.onFilter,
    this.activeFilters = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, size: 24, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('Percorso', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (onFilter != null)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onFilter!();
                },
                tooltip: 'Filtra argomenti',
              ),
              if (activeFilters > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$activeFilters',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        const SizedBox(width: 8),
      ],
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 1.0,
      shadowColor: colorScheme.shadow,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
