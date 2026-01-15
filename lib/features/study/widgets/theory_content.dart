// lib/features/study/widgets/theory_content.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TheoryContent extends StatelessWidget {
  final String theory;

  const TheoryContent({
    super.key,
    required this.theory,
  });

  @override
  Widget build(BuildContext context) {
    final paragraphs = theory.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildParagraph(context, paragraph),
        );
      }).toList(),
    );
  }

  Widget _buildParagraph(BuildContext context, String paragraph) {
    final lines = paragraph.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // 불릿 포인트 처리
        if (line.trim().startsWith('•') || line.trim().startsWith('-')) {
          return _buildBulletPoint(context, line);
        }
        // 일반 텍스트
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            line,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String line) {
    // "• " 또는 "- " 제거
    final content = line.trim().replaceFirst(RegExp(r'^[•\-]\s*'), '');

    // 키:값 형태 처리 (예: "주요 유적: 연천 전곡리...")
    final colonIndex = content.indexOf(':');

    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: colonIndex > 0
                ? _buildKeyValueText(context, content, colonIndex)
                : Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValueText(BuildContext context, String content, int colonIndex) {
    final key = content.substring(0, colonIndex);
    final value = content.substring(colonIndex + 1).trim();

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: '$key: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
