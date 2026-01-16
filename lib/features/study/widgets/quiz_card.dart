// lib/features/study/widgets/quiz_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/question.dart';
import 'option_button.dart';
import 'question_header.dart';
import 'explanation_card.dart';

class QuizCard extends StatefulWidget {
  final Question question;
  final VoidCallback onNext;
  final void Function(bool isCorrect, String? selectedAnswer) onAnswered;

  const QuizCard({
    super.key,
    required this.question,
    required this.onNext,
    required this.onAnswered,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  late List<String> _shuffledOptions;
  int? _selectedIndex;
  bool _showFeedback = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _shuffledOptions = widget.question.getShuffledOptions();
  }

  @override
  void didUpdateWidget(QuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _shuffledOptions = widget.question.getShuffledOptions();
        _selectedIndex = null;
        _showFeedback = false;
        _showHint = false;
      });
    }
  }

  void _onHintTap() {
    setState(() {
      _showHint = true;
    });
  }

  int get _correctIndex => _shuffledOptions.indexOf(widget.question.correct);
  bool get _isCorrect => _selectedIndex == _correctIndex;

  void _onOptionTap(int index) {
    if (_showFeedback) return;

    setState(() {
      _selectedIndex = index;
      _showFeedback = true;
    });

    final selectedAnswer = _shuffledOptions[index];
    widget.onAnswered(_isCorrect, selectedAnswer);
  }

  OptionState _getOptionState(int index) {
    if (!_showFeedback) {
      return _selectedIndex == index
          ? OptionState.selected
          : OptionState.normal;
    }

    // 피드백 상태
    if (index == _correctIndex) {
      return OptionState.correct;
    }
    if (index == _selectedIndex) {
      return OptionState.wrong;
    }
    return OptionState.disabled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 퀴즈 헤더
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.quiz,
                color: AppColors.secondary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '퀴즈',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),

        // 문제 및 선지
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 문제 헤더 (이미지/사료/텍스트)
                QuestionHeader(question: widget.question),

                const SizedBox(height: 16),

                // 힌트 버튼 및 힌트 표시
                if (widget.question.hasHint && !_showFeedback) ...[
                  if (!_showHint)
                    Center(
                      child: TextButton.icon(
                        onPressed: _onHintTap,
                        icon: const Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        label: const Text(
                          '힌트 보기',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.question.hint!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                ] else ...[
                  const SizedBox(height: 4),
                ],

                // 선지 목록
                ...List.generate(
                  _shuffledOptions.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OptionButton(
                      index: index,
                      text: _shuffledOptions[index],
                      state: _getOptionState(index),
                      onTap: () => _onOptionTap(index),
                    ),
                  ),
                ),

                // 해설 (피드백 시)
                if (_showFeedback) ...[
                  const SizedBox(height: 16),
                  ExplanationCard(
                    explanation: widget.question.explanation,
                    isCorrect: _isCorrect,
                  ),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // 하단 버튼 (피드백 시에만 표시)
        if (_showFeedback)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '다음 문제',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
