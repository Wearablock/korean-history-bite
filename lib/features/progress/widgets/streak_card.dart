// lib/features/progress/widgets/streak_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/study_providers.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(overallSummaryProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: summaryAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Text(l10n.error(e.toString())),
          data: (summary) {
            final currentStreak = summary['currentStreak'] as int;
            final longestStreak = summary['longestStreak'] as int;

            return Column(
              children: [
                // 헤더
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: AppColors.secondary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.streakRecord,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 스트릭 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StreakDisplay(
                      icon: Icons.local_fire_department,
                      iconColor: currentStreak > 0
                          ? AppColors.secondary
                          : Colors.grey,
                      value: currentStreak,
                      label: l10n.currentStreak,
                      isHighlighted: currentStreak > 0,
                    ),
                    Container(
                      height: 60,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _StreakDisplay(
                      icon: Icons.emoji_events,
                      iconColor: AppColors.warning,
                      value: longestStreak,
                      label: l10n.longestStreak,
                      isHighlighted: false,
                    ),
                  ],
                ),

                // 격려 메시지
                if (currentStreak > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getEncouragementMessage(currentStreak, longestStreak, l10n),
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _getEncouragementMessage(int current, int longest, AppLocalizations l10n) {
    if (current >= longest && current > 1) {
      return l10n.newRecord;
    } else if (current >= 7) {
      return l10n.weekStreak;
    } else if (current >= 3) {
      return l10n.keepItUp;
    } else {
      return l10n.todayComplete;
    }
  }
}

class _StreakDisplay extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int value;
  final String label;
  final bool isHighlighted;

  const _StreakDisplay({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Icon(icon, color: iconColor, size: 36),
        const SizedBox(height: 8),
        Text(
          l10n.daysCount(value),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isHighlighted ? AppColors.secondary : null,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
