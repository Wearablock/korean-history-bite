// lib/features/study/widgets/option_button.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum OptionState {
  normal,
  selected,
  correct,
  wrong,
  disabled,
}

class OptionButton extends StatelessWidget {
  final int index;
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  const OptionButton({
    super.key,
    required this.index,
    required this.text,
    required this.state,
    this.onTap,
  });

  static const _circledNumbers = ['①', '②', '③', '④', '⑤'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state == OptionState.normal ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor, width: 2),
        ),
        child: Row(
          children: [
            _buildLeading(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: _textColor,
                  fontWeight: _fontWeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    switch (state) {
      case OptionState.correct:
        return const Icon(Icons.check_circle, color: AppColors.correct, size: 24);
      case OptionState.wrong:
        return const Icon(Icons.cancel, color: AppColors.wrong, size: 24);
      default:
        return Text(
          _circledNumbers[index],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _numberColor,
          ),
        );
    }
  }

  Color get _backgroundColor {
    switch (state) {
      case OptionState.correct:
        return AppColors.correctLight;
      case OptionState.wrong:
        return AppColors.wrongLight;
      case OptionState.selected:
        return AppColors.secondary.withValues(alpha: 0.1);
      case OptionState.disabled:
        return Colors.grey[100]!;
      default:
        return Colors.white;
    }
  }

  Color get _borderColor {
    switch (state) {
      case OptionState.correct:
        return AppColors.correct;
      case OptionState.wrong:
        return AppColors.wrong;
      case OptionState.selected:
        return AppColors.secondary;
      default:
        return AppColors.dividerLight;
    }
  }

  Color get _textColor {
    switch (state) {
      case OptionState.disabled:
        return Colors.grey[500]!;
      default:
        return AppColors.textPrimaryLight;
    }
  }

  Color get _numberColor {
    switch (state) {
      case OptionState.selected:
        return AppColors.secondary;
      case OptionState.disabled:
        return Colors.grey[400]!;
      default:
        return AppColors.primary;
    }
  }

  FontWeight get _fontWeight {
    switch (state) {
      case OptionState.correct:
      case OptionState.wrong:
      case OptionState.selected:
        return FontWeight.w600;
      default:
        return FontWeight.normal;
    }
  }
}
