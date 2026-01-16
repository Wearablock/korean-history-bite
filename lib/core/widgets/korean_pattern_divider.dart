// lib/core/widgets/korean_pattern_divider.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 한국 전통 문양 장식 라인
/// 반복되는 원형 패턴으로 단청 느낌 표현
class KoreanPatternDivider extends StatelessWidget {
  final Color circleColor;
  final Color backgroundColor;
  final double circleSize;
  final double spacing;
  final double height;

  const KoreanPatternDivider({
    super.key,
    this.circleColor = AppColors.primary,
    this.backgroundColor = AppColors.secondary,
    this.circleSize = 8.0,
    this.spacing = 4.0,
    this.height = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final patternWidth = circleSize + spacing;
          final count = (constraints.maxWidth / patternWidth).floor();

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// 이중 원형 패턴 (경계선을 덮는 전통 스타일)
class KoreanDoublePatternDivider extends StatelessWidget {
  final Color circleColor;
  final Color borderColor;
  final Color topBackgroundColor;
  final double size;
  final double borderWidth;

  const KoreanDoublePatternDivider({
    super.key,
    this.circleColor = AppColors.secondary,
    this.borderColor = AppColors.primary,
    this.topBackgroundColor = AppColors.primary,
    this.size = 48.0,
    this.borderWidth = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final halfSize = size / 2;

    return SizedBox(
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 상단 배경만 (남색) - 원의 상반부
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: halfSize,
            child: Container(color: topBackgroundColor),
          ),
          // 원형 패턴 (경계를 덮음, 빈틈 없이)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = (constraints.maxWidth / size).ceil() + 1;
                final totalWidth = count * size;

                return ClipRect(
                  child: OverflowBox(
                    maxWidth: totalWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(count, (index) {
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: circleColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: borderColor,
                              width: borderWidth,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
