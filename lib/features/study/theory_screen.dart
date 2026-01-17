// lib/features/study/theory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../core/widgets/traditional_sign_title.dart';
import '../../data/providers/chapter_providers.dart';
import 'widgets/theory_card.dart';
import 'widgets/session_progress_bar.dart';

class TheoryScreen extends ConsumerWidget {
  final String chapterId;
  final int currentIndex;
  final int totalItems;
  final String? title;
  final VoidCallback? onCompleted;

  const TheoryScreen({
    super.key,
    required this.chapterId,
    this.currentIndex = 1,
    this.totalItems = 1,
    this.title,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final chapterAsync = ref.watch(chapterByIdProvider(chapterId));
    final progress = totalItems > 0 ? currentIndex / totalItems : 0.0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TraditionalSignTitle(title: title ?? l10n.newLearning),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$currentIndex/$totalItems',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // 진행률 바
          SessionProgressBar(progress: progress),

          // 이론 카드
          Expanded(
            child: chapterAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(l10n.error(error.toString()))),
              data: (chapter) {
                if (chapter == null) {
                  return Center(child: Text(l10n.chapterNotFound));
                }
                return TheoryCard(
                  chapter: chapter,
                  onCompleted: () {
                    if (onCompleted != null) {
                      onCompleted!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
