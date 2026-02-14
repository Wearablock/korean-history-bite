// lib/features/home/widgets/study_cta_button.dart

import 'package:flutter/material.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/study_service.dart';

class StudyCtaButton extends StatelessWidget {
  final TodaySummary summary;
  final VoidCallback onPressed;

  const StudyCtaButton({
    super.key,
    required this.summary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final buttonText = _getButtonText(l10n);
    final isAllCompleted = summary.allChaptersCompleted;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isAllCompleted ? AppColors.correct : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getButtonText(AppLocalizations l10n) {
    if (summary.allChaptersCompleted) {
      return l10n.startReview;
    }
    if (summary.todayStudiedChapters > 0) {
      return l10n.continueStudy;
    }
    return l10n.startStudy;
  }
}
