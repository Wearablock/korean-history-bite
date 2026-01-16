// lib/features/study/theory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/traditional_sign_title.dart';
import '../../data/providers/chapter_providers.dart';
import 'widgets/theory_card.dart';
import 'widgets/session_progress_bar.dart';

class TheoryScreen extends ConsumerWidget {
  final String chapterId;
  final int currentIndex;
  final int totalItems;
  final VoidCallback? onCompleted;

  const TheoryScreen({
    super.key,
    required this.chapterId,
    this.currentIndex = 1,
    this.totalItems = 1,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterAsync = ref.watch(chapterByIdProvider(chapterId));
    final progress = totalItems > 0 ? currentIndex / totalItems : 0.0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: TraditionalSignTitle(title: '신규 학습'),
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
              error: (error, _) => Center(child: Text('오류: $error')),
              data: (chapter) {
                if (chapter == null) {
                  return const Center(child: Text('챕터를 찾을 수 없습니다.'));
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
