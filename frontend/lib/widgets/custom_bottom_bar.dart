import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom navigation bar per Dydat.
/// Implementa la struttura a 3 tab: Home, I miei studi, Profilo.
///
/// Studio è una route fullscreen separata (fuori dalla shell) —
/// non appare nella bottom bar.
class CustomBottomBar extends StatelessWidget {
  /// Indice tab selezionato corrente
  final int currentIndex;

  /// Callback al tap su un tab
  final Function(int) onTap;

  /// Se la bottom bar deve essere visibile
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
              // Feedback aptico al cambio tab
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
                  icon: Icons.home_outlined,
                  isSelected: currentIndex == 0,
                ),
                activeIcon: _buildIcon(icon: Icons.home, isSelected: true),
                label: 'Home',
                tooltip: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  icon: Icons.menu_book_outlined,
                  isSelected: currentIndex == 1,
                ),
                activeIcon:
                    _buildIcon(icon: Icons.menu_book, isSelected: true),
                label: 'I miei studi',
                tooltip: 'I miei percorsi di apprendimento',
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

  /// Icona con sizing e touch target coerenti
  Widget _buildIcon({required IconData icon, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Icon(icon, size: 24),
    );
  }
}
