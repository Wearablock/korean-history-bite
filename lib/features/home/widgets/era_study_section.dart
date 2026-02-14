// lib/features/home/widgets/era_study_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/chapter_providers.dart';
import '../../../data/providers/era_providers.dart';
import '../../../data/providers/study_providers.dart';
import '../../../data/models/era.dart';
import '../../../services/study_service.dart';
import '../../study/study_session_screen.dart';

class EraStudySection extends ConsumerWidget {
  const EraStudySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final erasAsync = ref.watch(erasProvider);
    final progressAsync = ref.watch(eraProgressProvider);

    if (erasAsync.isLoading || progressAsync.isLoading) {
      return const SizedBox.shrink();
    }

    if (erasAsync.hasError || progressAsync.hasError) {
      return const SizedBox.shrink();
    }

    final eras = erasAsync.value!;
    final progressMap = progressAsync.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.eraStudy,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: eras.length,
            itemBuilder: (context, index) {
              final era = eras[index];
              final progress = progressMap[era.id];
              final locale = ref.watch(currentLocaleProvider);

              return Padding(
                padding: EdgeInsets.only(
                  right: index < eras.length - 1 ? 12 : 0,
                ),
                child: _EraStudyCard(
                  era: era,
                  locale: locale,
                  progress: progress,
                  eraColor: era.themeColor ?? _getDefaultEraColor(era.id),
                  l10n: l10n,
                  onTap: () => _startEraSession(context, era.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _startEraSession(BuildContext context, String eraId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudySessionScreen(eraId: eraId),
      ),
    );
  }

  Color _getDefaultEraColor(String eraId) {
    const colors = {
      'prehistoric': AppColors.eraPrehistoric,
      'gojoseon': AppColors.eraGojoseon,
      'three_kingdoms': AppColors.eraThreeKingdoms,
      'north_south_states': AppColors.eraUnifiedSilla,
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

class _EraStudyCard extends StatelessWidget {
  final Era era;
  final String locale;
  final EraProgress? progress;
  final Color eraColor;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _EraStudyCard({
    required this.era,
    required this.locale,
    required this.progress,
    required this.eraColor,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final studiedProgress = progress?.studiedProgress ?? 0.0;
    final isAllStudied = progress != null &&
        progress!.studiedQuestions >= progress!.totalQuestions &&
        progress!.totalQuestions > 0;

    return SizedBox(
      width: 140,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isAllStudied ? null : onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 시대 색상 헤더
              Container(
                height: 6,
                color: eraColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 시대 이름
                      Text(
                        era.getName(locale),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // 문제 수
                      Text(
                        l10n.questionsCount(progress?.totalQuestions ?? 0),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      // 진행률 바
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: studiedProgress.clamp(0.0, 1.0),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: eraColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // 퍼센트 또는 완료 표시
                      Text(
                        isAllStudied
                            ? l10n.eraAllStudied
                            : '${(studiedProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isAllStudied ? eraColor : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
