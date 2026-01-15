// lib/features/study/widgets/session_progress_bar.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SessionProgressBar extends StatelessWidget {
  final double progress;
  final String? label;

  const SessionProgressBar({
    super.key,
    required this.progress,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.dividerLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
