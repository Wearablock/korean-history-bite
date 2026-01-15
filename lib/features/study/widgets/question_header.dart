// lib/features/study/widgets/question_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/question.dart';
import '../../../data/providers/image_providers.dart';
import '../../../data/providers/chapter_providers.dart';
import 'source_box.dart';

class QuestionHeader extends ConsumerWidget {
  final Question question;

  const QuestionHeader({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이미지 (이미지형 문제)
        if (question.hasImage) _buildImage(ref),

        // 사료 (사료형 문제)
        if (question.hasSource) ...[
          SourceBox(source: question.source!),
          const SizedBox(height: 16),
        ],

        // 문제 텍스트
        Text(
          'Q. ${question.question}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(WidgetRef ref) {
    final locale = ref.watch(currentLocaleProvider);
    final imageAsync = ref.watch(imageByIdProvider(question.imageId!));

    return imageAsync.when(
      loading: () => Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.dividerLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (imageMeta) {
        if (imageMeta == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imageMeta.fullPath,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: AppColors.dividerLight,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                imageMeta.getCaption(locale),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
