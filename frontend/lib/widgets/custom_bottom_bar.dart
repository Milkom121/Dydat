import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom bottom navigation bar for Dydat AI tutoring app.
/// Implements the three-tab structure: Studio, Percorso, Profilo.
///
/// Features:
/// - Gesture-aware navigation with swipe-to-reveal capability
/// - Contextual hiding during focused study sessions
/// - Haptic feedback on tab selection
/// - Material 3 elevation system
/// - Amber accent branding
class CustomBottomBar extends StatelessWidget {
  /// Current selected tab index
  final int currentIndex;

  /// Callback when a tab is tapped
  final Function(int) onTap;

  /// Whether the bottom bar should be visible
  final bool isVisible;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              // Provide haptic feedback on tab selection
              HapticFeedback.lightImpact();
              onTap(index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: theme.brightness == Brightness.light
                ? const Color(0x99000000) // textMediumEmphasisLight
                : const Color(0x99FFFFFF), // textMediumEmphasisDark
            selectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w400,
            ),
            items: [
              BottomNavigationBarItem(
                icon: _buildIcon(
                  icon: Icons.school_outlined,
                  isSelected: currentIndex == 0,
                ),
                activeIcon: _buildIcon(icon: Icons.school, isSelected: true),
                label: 'Studio',
                tooltip: 'Sessione di studio AI',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  icon: Icons.timeline_outlined,
                  isSelected: currentIndex == 1,
                ),
                activeIcon: _buildIcon(icon: Icons.timeline, isSelected: true),
                label: 'Percorso',
                tooltip: 'Visualizza il tuo percorso di apprendimento',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  icon: Icons.person_outline,
                  isSelected: currentIndex == 2,
                ),
                activeIcon: _buildIcon(icon: Icons.person, isSelected: true),
                label: 'Profilo',
                tooltip: 'Dashboard personale e impostazioni',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an icon with consistent sizing and touch target
  Widget _buildIcon({required IconData icon, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Icon(icon, size: 24),
    );
  }
}

