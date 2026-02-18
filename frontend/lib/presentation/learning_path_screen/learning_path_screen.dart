import 'package:flutter/material.dart';
import '../../core/sizer_extensions.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/empty_state_widget.dart';
import './widgets/tema_card_widget.dart';
import './widgets/tema_detail_bottom_sheet.dart';

/// Learning Path Screen - Visualizes personalized STEM learning progression
/// Tab 1 in bottom navigation with pull-to-refresh capability
class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  final String _selectedSubject = 'Matematica';
  final int _currentTemaIndex = 2; // Current tema being studied

  // Mock data for learning path
  final List<Map<String, dynamic>> _temaList = [
    {
      "id": 1,
      "title": "Equazioni di Primo Grado",
      "progress": 1.0,
      "status": "completed",
      "nodes": [
        {"name": "Introduzione alle equazioni", "completed": true},
        {"name": "Risoluzione base", "completed": true},
        {"name": "Problemi applicativi", "completed": true},
      ],
    },
    {
      "id": 2,
      "title": "Sistemi Lineari",
      "progress": 1.0,
      "status": "completed",
      "nodes": [
        {"name": "Metodo di sostituzione", "completed": true},
        {"name": "Metodo di eliminazione", "completed": true},
        {"name": "Interpretazione geometrica", "completed": true},
      ],
    },
    {
      "id": 3,
      "title": "Funzioni Quadratiche",
      "progress": 0.65,
      "status": "current",
      "nodes": [
        {"name": "Forma standard", "completed": true},
        {"name": "Vertice e asse di simmetria", "completed": true},
        {"name": "Grafico della parabola", "completed": false},
        {"name": "Applicazioni pratiche", "completed": false},
      ],
    },
    {
      "id": 4,
      "title": "Trigonometria Base",
      "progress": 0.0,
      "status": "next",
      "nodes": [
        {"name": "Angoli e radianti", "completed": false},
        {"name": "Funzioni trigonometriche", "completed": false},
        {"name": "Identità fondamentali", "completed": false},
      ],
    },
    {
      "id": 5,
      "title": "Limiti e Continuità",
      "progress": 0.0,
      "status": "future",
      "nodes": [
        {"name": "Concetto di limite", "completed": false},
        {"name": "Calcolo dei limiti", "completed": false},
        {"name": "Funzioni continue", "completed": false},
      ],
    },
    {
      "id": 6,
      "title": "Derivate",
      "progress": 0.0,
      "status": "future",
      "nodes": [
        {"name": "Definizione di derivata", "completed": false},
        {"name": "Regole di derivazione", "completed": false},
        {"name": "Applicazioni delle derivate", "completed": false},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTema();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Auto-scroll to current tema with smooth animation
  void _scrollToCurrentTema() {
    if (_currentTemaIndex >= 0 && _currentTemaIndex < _temaList.length) {
      final double itemHeight = 20.h; // Approximate card height
      final double targetOffset = _currentTemaIndex * itemHeight - (30.h);

      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isRefreshing = false);
  }

  /// Show tema detail bottom sheet
  void _showTemaDetail(Map<String, dynamic> tema) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TemaDetailBottomSheet(
        tema: tema,
        onStudyPressed: () {
          Navigator.pop(context);
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed('/studio-screen');
        },
      ),
    );
  }

  /// Calculate overall progress
  double _calculateOverallProgress() {
    if (_temaList.isEmpty) return 0.0;
    double totalProgress = _temaList.fold(
      0.0,
      (sum, tema) => sum + (tema["progress"] as double),
    );
    return totalProgress / _temaList.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overallProgress = _calculateOverallProgress();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomPercorsoAppBar(
        progress: overallProgress,
        onFilter: () {
          // Filter functionality placeholder
        },
        activeFilters: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: _temaList.isEmpty
              ? EmptyStateWidget(
                  onStartLearning: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed('/studio-screen');
                  },
                )
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: theme.colorScheme.primary,
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    itemCount: _temaList.length,
                    separatorBuilder: (context, index) => SizedBox(height: 2.h),
                    itemBuilder: (context, index) {
                      final tema = _temaList[index];
                      final isCurrent = index == _currentTemaIndex;

                      return TemaCardWidget(
                        tema: tema,
                        isCurrent: isCurrent,
                        onTap: () => _showTemaDetail(tema),
                        onLongPress: tema["status"] == "completed"
                            ? () {
                                // Show review options context menu
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Opzioni di revisione per ${tema["title"]}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            : null,
                      );
                    },
                  ),
                ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: CustomBottomBar(
          currentIndex: 1,
          onTap: (index) {
            if (index != 1) {
              final route = CustomBottomBarNavigation.getRouteForIndex(index);
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushReplacementNamed(route);
            }
          },
        ),
      ),
    );
  }
}
