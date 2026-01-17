// lib/features/study/widgets/theory_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/chapter.dart';
import '../../../data/providers/chapter_providers.dart';
import '../../../data/providers/image_providers.dart';
import 'image_slider.dart';
import 'theory_content.dart';

class TheoryCard extends ConsumerWidget {
  final Chapter chapter;
  final VoidCallback onCompleted;

  const TheoryCard({
    super.key,
    required this.chapter,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(currentLocaleProvider);
    final imagesAsync = ref.watch(imagesByIdsProvider(chapter.images));

    return Column(
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.menu_book,
                color: AppColors.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.theoryLearning,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),

        // 이론 카드 본문
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 챕터 제목
                    Text(
                      chapter.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // 이미지 슬라이더
                    imagesAsync.when(
                      loading: () => const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (images) {
                        if (images.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            ImageSlider(
                              images: images,
                              locale: locale,
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),

                    // 이론 내용
                    TheoryContent(theory: chapter.theory),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 하단 버튼
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onCompleted,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.learningComplete,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
