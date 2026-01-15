// lib/features/home/widgets/review_alert_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 복습 알림 카드
/// 복습할 문제가 있을 때 홈 화면에 표시
class ReviewAlertCard extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const ReviewAlertCard({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF3E0), // 따뜻한 오렌지 배경
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.secondary,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.replay,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '복습할 문제가 있어요!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count개의 문제가 복습을 기다려요',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              // 화살표
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.secondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
