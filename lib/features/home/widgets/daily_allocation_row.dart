// lib/features/home/widgets/daily_allocation_row.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/question_selector.dart';

class DailyAllocationRow extends StatelessWidget {
  final DailyAllocation allocation;

  const DailyAllocationRow({
    super.key,
    required this.allocation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildAllocationItem(
            context,
            label: '오답 복습',
            count: allocation.wrongReview,
            color: AppColors.wrong,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAllocationItem(
            context,
            label: '복습',
            count: allocation.spacedReview,
            color: AppColors.progressReview,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAllocationItem(
            context,
            label: '신규',
            count: allocation.newLearning,
            color: AppColors.progressNew,
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationItem(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count개',
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
