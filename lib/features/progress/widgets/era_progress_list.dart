// lib/features/progress/widgets/era_progress_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/chapter_providers.dart';
import '../../../data/providers/era_providers.dart';
import '../../../data/providers/study_providers.dart';
import '../../../services/study_service.dart';

class EraProgressList extends ConsumerWidget {
  const EraProgressList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final erasAsync = ref.watch(erasProvider);
    final progressAsync = ref.watch(eraProgressProvider);
    final locale = ref.watch(currentLocaleProvider);

    // 두 AsyncValue 중 하나라도 로딩/에러면 해당 상태 표시
    if (erasAsync.isLoading || progressAsync.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (erasAsync.hasError) {
      return Center(child: Text('오류: ${erasAsync.error}'));
    }
    if (progressAsync.hasError) {
      return Center(child: Text('오류: ${progressAsync.error}'));
    }

    final eras = erasAsync.value!;
    final progressMap = progressAsync.value!;

    // Column으로 대체 (shrinkWrap ListView보다 효율적)
    return Column(
      children: [
        for (int i = 0; i < eras.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          EraProgressTile(
            eraName: eras[i].getName(locale),
            eraColor: eras[i].themeColor ?? _getDefaultEraColor(eras[i].id),
            progress: progressMap[eras[i].id],
          ),
        ],
      ],
    );
  }

  Color _getDefaultEraColor(String eraId) {
    const colors = {
      'prehistoric': AppColors.eraPrehistoric,
      'gojoseon': AppColors.eraGojoseon,
      'three_kingdoms': AppColors.eraThreeKingdoms,
      'unified_silla': AppColors.eraUnifiedSilla,
      'goryeo': AppColors.eraGoryeo,
      'joseon_early': AppColors.eraJoseon,
      'joseon_late': AppColors.eraJoseon,
      'modern': AppColors.eraModern,
      'japanese_occupation': AppColors.eraModern,
      'contemporary': AppColors.eraModern,
    };
    return colors[eraId] ?? AppColors.primary;
  }
}

class EraProgressTile extends StatelessWidget {
  final String eraName;
  final Color eraColor;
  final EraProgress? progress;

  const EraProgressTile({
    super.key,
    required this.eraName,
    required this.eraColor,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final masteredProgress = progress?.masteredProgress ?? 0.0;
    final studiedProgress = progress?.studiedProgress ?? 0.0;
    final total = progress?.totalQuestions ?? 0;
    final studied = progress?.studiedQuestions ?? 0;
    final mastered = progress?.masteredQuestions ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시대 이름과 퍼센트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: eraColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    eraName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              Text(
                '${(masteredProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: eraColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 이중 진행률 바 (학습 + 완전습득)
          Stack(
            children: [
              // 배경 (전체)
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // 학습 진행률
              FractionallySizedBox(
                widthFactor: studiedProgress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: eraColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // 완전습득 진행률
              FractionallySizedBox(
                widthFactor: masteredProgress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: eraColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 상세 정보
          Text(
            '학습 $studied/$total · 완전습득 $mastered',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}
