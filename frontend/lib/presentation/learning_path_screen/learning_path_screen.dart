import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/sizer_extensions.dart';

import '../../models/tema.dart';
import '../../providers/path_provider.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/empty_state_widget.dart';
import './widgets/tema_card_widget.dart';
import './widgets/tema_detail_bottom_sheet.dart';

/// Learning Path Screen - Visualizes personalized STEM learning progression
/// Tab 1 in bottom navigation with pull-to-refresh capability.
/// Uses path_provider to load real data from the API.
class LearningPathScreen extends ConsumerStatefulWidget {
  const LearningPathScreen({super.key});

  @override
  ConsumerState<LearningPathScreen> createState() =>
      _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load topics on first build
    Future.microtask(() {
      ref.read(pathProvider.notifier).loadTopics();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle pull-to-refresh — reload topics from API
  Future<void> _handleRefresh() async {
    await ref.read(pathProvider.notifier).loadTopics();
  }

  /// Show tema detail bottom sheet
  void _showTemaDetail(Tema tema) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TemaDetailBottomSheet(
        tema: tema,
        onStudyPressed: () {
          Navigator.pop(context);
          context.go('/studio');
        },
      ),
    );
  }

  /// Calculate overall progress from all topics
  double _calculateOverallProgress(List<Tema> topics) {
    if (topics.isEmpty) return 0.0;
    int totalNodi = 0;
    int completedNodi = 0;
    for (final t in topics) {
      totalNodi += t.nodiTotali;
      completedNodi += t.nodiCompletati;
    }
    if (totalNodi == 0) return 0.0;
    return completedNodi / totalNodi;
  }

  /// Find the index of the first "current" (in-progress) tema
  int _findCurrentTemaIndex(List<Tema> topics) {
    for (int i = 0; i < topics.length; i++) {
      if (!topics[i].completato && topics[i].nodiCompletati > 0) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pathState = ref.watch(pathProvider);
    final topics = pathState.topics;
    final isLoading = pathState.isLoading;
    final error = pathState.error;
    final overallProgress = _calculateOverallProgress(topics);
    final currentTemaIndex = _findCurrentTemaIndex(topics);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomPercorsoAppBar(
        progress: overallProgress,
        onFilter: () {},
        activeFilters: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: _buildBody(
            theme,
            topics,
            isLoading,
            error,
            currentTemaIndex,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    List<Tema> topics,
    bool isLoading,
    String? error,
    int currentTemaIndex,
  ) {
    // Initial loading state
    if (isLoading && topics.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      );
    }

    // Error state with no data
    if (error != null && topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => ref.read(pathProvider.notifier).loadTopics(),
              child: Text('Riprova'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (topics.isEmpty) {
      return EmptyStateWidget(
        onStartLearning: () {
          context.go('/studio');
        },
      );
    }

    // Data loaded — show topic list
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: theme.colorScheme.primary,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 2.h),
        itemCount: topics.length,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          final tema = topics[index];
          final isCurrent = index == currentTemaIndex;

          return TemaCardWidget(
            tema: tema,
            isCurrent: isCurrent,
            onTap: () => _showTemaDetail(tema),
            onLongPress: tema.completato
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Opzioni di revisione per ${tema.nome}',
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
    );
  }
}
