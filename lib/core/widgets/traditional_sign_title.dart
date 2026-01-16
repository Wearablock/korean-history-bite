// lib/core/widgets/traditional_sign_title.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 전통 간판 스타일 타이틀
/// 두꺼운 갈색 테두리 + 흰색 배경 + 검정 글씨
class TraditionalSignTitle extends StatelessWidget {
  final String title;

  const TraditionalSignTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.signBackground,
        border: Border.all(
          color: AppColors.signBorder,
          width: 6,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.black,
          fontSize: 27,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
