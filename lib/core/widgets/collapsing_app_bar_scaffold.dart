// lib/core/widgets/collapsing_app_bar_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'korean_pattern_divider.dart';

/// 스크롤 시 앱바가 부드럽게 줄어드는 스캐폴드
class CollapsingAppBarScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showPattern;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? bottomWidget;

  const CollapsingAppBarScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showPattern = true,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottomWidget,
  });

  static const double _patternHeight = 48.0;
  static const double _expandedHeight = 100.0 + _patternHeight;
  static const double _collapsedHeight = 64.0 + _patternHeight;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 다크모드에 따른 색상 설정
    final appBarColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final bottomColor = isDark ? AppColors.backgroundDark : AppColors.white;
    final patternCircleColor = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final patternBorderColor = isDark ? AppColors.primaryDark : AppColors.primary;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: _expandedHeight,
                  collapsedHeight: _collapsedHeight,
                  pinned: true,
                  stretch: true,
                  backgroundColor: appBarColor,
                  foregroundColor: AppColors.white,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  leading: leading,
                  automaticallyImplyLeading: automaticallyImplyLeading,
                  actions: actions,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxHeight = _expandedHeight + statusBarHeight;
                      final minHeight = _collapsedHeight + statusBarHeight;
                      final currentHeight = constraints.maxHeight;
                      final expandRatio =
                          ((currentHeight - minHeight) / (maxHeight - minHeight))
                              .clamp(0.0, 1.0);

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // 배경: 상단 남색, 하단 (다크모드: 어두운 배경, 라이트모드: 흰색)
                          Column(
                            children: [
                              Expanded(child: Container(color: appBarColor)),
                              if (showPattern)
                                Container(
                                  height: _patternHeight / 2,
                                  color: bottomColor,
                                ),
                            ],
                          ),
                          // 타이틀
                          Positioned(
                            top: statusBarHeight,
                            left: 0,
                            right: 0,
                            bottom: showPattern ? _patternHeight : 0,
                            child: Center(
                              child: AnimatedSignTitle(
                                title: title,
                                expandRatio: expandRatio,
                                isDark: isDark,
                              ),
                            ),
                          ),
                          // 이중 원형 패턴 (하단에 고정)
                          if (showPattern)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: KoreanDoublePatternDivider(
                                circleColor: patternCircleColor,
                                borderColor: patternBorderColor,
                                topBackgroundColor: appBarColor,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: showPattern ? _patternHeight / 2 : 0),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
          // 하단 위젯 (배너 광고 등)
          if (bottomWidget != null) bottomWidget!,
        ],
      ),
    );
  }
}

/// 스크롤에 따라 크기가 변하는 간판 타이틀
class AnimatedSignTitle extends StatelessWidget {
  final String title;
  final double expandRatio;
  final bool isDark;

  const AnimatedSignTitle({
    super.key,
    required this.title,
    required this.expandRatio,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    // 축소 시 크기 조절
    final scale = 0.7 + (0.3 * expandRatio); // 0.7 ~ 1.0
    final borderWidth = 4.0 + (2.0 * expandRatio); // 4 ~ 6
    final horizontalPadding = 16.0 + (8.0 * expandRatio); // 16 ~ 24
    final verticalPadding = 6.0 + (4.0 * expandRatio); // 6 ~ 10
    final fontSize = 20.0 + (7.0 * expandRatio); // 20 ~ 27

    // 다크모드에 따른 간판 색상
    final signBackground = isDark
        ? AppColors.surfaceDark
        : AppColors.signBackground;
    final signBorder = isDark
        ? AppColors.grey600
        : AppColors.signBorder;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.black;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: signBackground,
        border: Border.all(
          color: signBorder,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2 * expandRatio),
            offset: Offset(2 * expandRatio, 2 * expandRatio),
            blurRadius: 4 * expandRatio,
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 2 * scale,
        ),
      ),
    );
  }
}
