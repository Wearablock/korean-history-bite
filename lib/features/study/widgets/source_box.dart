// lib/features/study/widgets/source_box.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SourceBox extends StatelessWidget {
  final String source;

  const SourceBox({
    super.key,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.history_edu,
                size: 18,
                color: AppColors.secondary,
              ),
              SizedBox(width: 6),
              Text(
                '사료',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$source"',
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textPrimaryLight,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
