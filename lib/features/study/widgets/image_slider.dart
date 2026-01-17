// lib/features/study/widgets/image_slider.dart

import 'package:flutter/material.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../../core/config/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/image_meta.dart';

class ImageSlider extends StatefulWidget {
  final List<ImageMeta> images;
  final String locale;

  const ImageSlider({
    super.key,
    required this.images,
    this.locale = 'ko',
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();
  // ValueNotifier로 변경하여 부분 리빌드만 발생
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  bool get _hasMultipleImages => widget.images.length > 1;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // 이미지 슬라이더
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              // PageView
              PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  _currentPage.value = index;
                },
                itemBuilder: (context, index) {
                  final image = widget.images[index];
                  return _buildImageItem(image);
                },
              ),

              // 좌측 화살표 (ValueListenableBuilder로 부분 리빌드)
              if (_hasMultipleImages)
                ValueListenableBuilder<int>(
                  valueListenable: _currentPage,
                  builder: (context, currentPage, child) {
                    if (currentPage <= 0) return const SizedBox.shrink();
                    return Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: _buildArrowButton(
                        icon: Icons.chevron_left,
                        onTap: () => _pageController.previousPage(
                          duration: UIConstants.mediumAnimation,
                          curve: Curves.easeInOut,
                        ),
                      ),
                    );
                  },
                ),

              // 우측 화살표 (ValueListenableBuilder로 부분 리빌드)
              if (_hasMultipleImages)
                ValueListenableBuilder<int>(
                  valueListenable: _currentPage,
                  builder: (context, currentPage, child) {
                    if (currentPage >= widget.images.length - 1) {
                      return const SizedBox.shrink();
                    }
                    return Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: _buildArrowButton(
                        icon: Icons.chevron_right,
                        onTap: () => _pageController.nextPage(
                          duration: UIConstants.mediumAnimation,
                          curve: Curves.easeInOut,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 캡션 (ValueListenableBuilder로 부분 리빌드)
        ValueListenableBuilder<int>(
          valueListenable: _currentPage,
          builder: (context, currentPage, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.images[currentPage].getCaption(widget.locale),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grey700,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),

        // 페이지 인디케이터
        if (_hasMultipleImages) ...[
          const SizedBox(height: 8),
          _buildPageIndicator(),
        ],
      ],
    );
  }

  Widget _buildImageItem(ImageMeta image) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.dividerLight,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        image.fullPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          final l10n = AppLocalizations.of(context)!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: AppColors.grey400,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.imageLoadFailed,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        color: Colors.black.withValues(alpha: 0.2),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPage,
      builder: (context, currentPage, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.images.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentPage
                    ? AppColors.secondary
                    : AppColors.dividerLight,
              ),
            ),
          ),
        );
      },
    );
  }
}
