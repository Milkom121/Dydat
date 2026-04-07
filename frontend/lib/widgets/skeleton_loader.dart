import 'package:flutter/material.dart';

/// Widget skeleton con animazione shimmer per stati di caricamento.
/// Sostituisce i CircularProgressIndicator con placeholder visivi
/// che anticipano la forma del contenuto reale.
///
/// Uso:
/// ```dart
/// SkeletonBox(width: 100, height: 20)
/// SkeletonLine(width: double.infinity)
/// SkeletonCard(height: 120)
/// ```

// ---------------------------------------------------------------------------
// Shimmer wrapper — gestisce l'animazione condivisa
// ---------------------------------------------------------------------------

/// Container che applica l'animazione shimmer ai figli skeleton.
/// Wrappa un gruppo di skeleton per condividere un unico AnimationController.
class ShimmerGroup extends StatefulWidget {
  final Widget child;

  const ShimmerGroup({super.key, required this.child});

  @override
  State<ShimmerGroup> createState() => _ShimmerGroupState();
}

class _ShimmerGroupState extends State<ShimmerGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerScope(animation: _controller, child: widget.child);
  }
}

/// InheritedWidget che distribuisce l'animazione ai discendenti.
class _ShimmerScope extends InheritedWidget {
  final Animation<double> animation;

  const _ShimmerScope({required this.animation, required super.child});

  static _ShimmerScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ShimmerScope>();
  }

  @override
  bool updateShouldNotify(_ShimmerScope oldWidget) =>
      animation != oldWidget.animation;
}

// ---------------------------------------------------------------------------
// Componenti skeleton
// ---------------------------------------------------------------------------

/// Rettangolo skeleton con shimmer. Blocco base per comporre layout.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = _ShimmerScope.of(context);

    final baseColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surface;

    // Se non c'e ShimmerGroup, mostra il box statico
    if (scope == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    return AnimatedBuilder(
      animation: scope.animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * scope.animation.value, 0),
              end: Alignment(-1.0 + 2.0 * scope.animation.value + 1.0, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Linea di testo skeleton. Altezza fissa 14px, larghezza configurabile.
class SkeletonLine extends StatelessWidget {
  final double? width;

  const SkeletonLine({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: 14,
      borderRadius: 4,
    );
  }
}

/// Card skeleton con padding interno e linee testo.
class SkeletonCard extends StatelessWidget {
  final double? height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.height,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 140),
          const SizedBox(height: 12),
          const SkeletonLine(),
          const SizedBox(height: 8),
          SkeletonLine(width: MediaQuery.of(context).size.width * 0.5),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layout skeleton pre-composti per le schermate principali
// ---------------------------------------------------------------------------

/// Skeleton per la schermata "I miei studi" (mappa percorso).
class LearningPathSkeleton extends StatelessWidget {
  const LearningPathSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: List.generate(5, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  // Cerchio nodo
                  const SkeletonBox(width: 56, height: 56, borderRadius: 28),
                  const SizedBox(width: 16),
                  // Nome nodo + stato
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLine(width: 80.0 + i * 20),
                        const SizedBox(height: 8),
                        const SkeletonLine(width: 60),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Skeleton per la schermata Quaderno nodo.
class QuadernoSkeleton extends StatelessWidget {
  const QuadernoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          // Header stato
          SkeletonBox(height: 80, borderRadius: 16),
          SizedBox(height: 16),
          // Breadcrumb
          SkeletonLine(width: 200),
          SizedBox(height: 20),
          // Parole chiave (chip)
          Row(
            children: [
              SkeletonBox(width: 70, height: 28, borderRadius: 14),
              SizedBox(width: 8),
              SkeletonBox(width: 90, height: 28, borderRadius: 14),
              SizedBox(width: 8),
              SkeletonBox(width: 60, height: 28, borderRadius: 14),
            ],
          ),
          SizedBox(height: 24),
          // Sezione titolo
          SkeletonLine(width: 150),
          SizedBox(height: 12),
          // Testo collassabile
          SkeletonBox(height: 60, borderRadius: 12),
          SizedBox(height: 24),
          // Sezione formule
          SkeletonLine(width: 130),
          SizedBox(height: 12),
          SkeletonCard(),
          SizedBox(height: 12),
          SkeletonCard(),
        ],
      ),
    );
  }
}

/// Skeleton per la schermata Recap sessione.
class RecapSkeleton extends StatelessWidget {
  const RecapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Narrativa tutor
            const SkeletonBox(height: 100, borderRadius: 16),
            const SizedBox(height: 24),
            // Stats cards (2x2 grid)
            Row(
              children: [
                Expanded(
                  child: SkeletonBox(height: 80, borderRadius: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SkeletonBox(height: 80, borderRadius: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SkeletonBox(height: 80, borderRadius: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SkeletonBox(height: 80, borderRadius: 12),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Nodi lavorati
            const SkeletonLine(width: 140),
            const SizedBox(height: 12),
            const SkeletonBox(height: 48, borderRadius: 12),
            const SizedBox(height: 8),
            const SkeletonBox(height: 48, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

/// Skeleton per la schermata Profilo.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          // Identity card
          SkeletonBox(height: 100, borderRadius: 16),
          SizedBox(height: 16),
          // Stats card
          SkeletonBox(height: 120, borderRadius: 16),
          SizedBox(height: 16),
          // Achievement section
          SkeletonLine(width: 130),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SkeletonBox(height: 70, borderRadius: 12)),
              SizedBox(width: 8),
              Expanded(child: SkeletonBox(height: 70, borderRadius: 12)),
              SizedBox(width: 8),
              Expanded(child: SkeletonBox(height: 70, borderRadius: 12)),
            ],
          ),
          SizedBox(height: 16),
          // Theme card
          SkeletonBox(height: 60, borderRadius: 16),
        ],
      ),
    );
  }
}
