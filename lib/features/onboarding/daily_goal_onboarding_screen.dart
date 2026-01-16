// lib/features/onboarding/daily_goal_onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/setting_keys.dart';
import '../../data/providers/database_providers.dart';

/// 최초 실행 시 일일 학습량 설정 온보딩 화면
class DailyGoalOnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const DailyGoalOnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<DailyGoalOnboardingScreen> createState() =>
      _DailyGoalOnboardingScreenState();
}

class _DailyGoalOnboardingScreenState
    extends ConsumerState<DailyGoalOnboardingScreen> {
  int _selectedChapterCount = 1;
  bool _isCustom = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),

              // 아이콘
              Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: 24),

              // 제목
              Text(
                '환영합니다!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 설명
              Text(
                '하루에 몇 챕터를 공부할까요?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                '나중에 설정에서 변경할 수 있어요',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // 챕터 선택 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      // 기본 옵션들
                      ...DailyGoalOption.values.map((option) {
                        final isSelected = !_isCustom &&
                            _selectedChapterCount == option.chapterCount;
                        return _buildOptionTile(
                          title: option.label,
                          subtitle: _getOptionDescription(option.chapterCount),
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedChapterCount = option.chapterCount;
                              _isCustom = false;
                            });
                          },
                        );
                      }),

                      const Divider(height: 1),

                      // 커스텀 옵션
                      _buildOptionTile(
                        title: '직접 설정',
                        subtitle: _isCustom ? '$_selectedChapterCount챕터' : null,
                        isSelected: _isCustom,
                        onTap: () {
                          setState(() {
                            _isCustom = true;
                          });
                        },
                      ),

                      // 커스텀 슬라이더
                      if (_isCustom) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              const Text('1'),
                              Expanded(
                                child: Slider(
                                  value: _selectedChapterCount.toDouble(),
                                  min: 1,
                                  max: 5,
                                  divisions: 4,
                                  label: '$_selectedChapterCount챕터',
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedChapterCount = value.round();
                                    });
                                  },
                                ),
                              ),
                              const Text('5'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // 시작 버튼
              FilledButton(
                onPressed: _isSaving ? null : _saveAndContinue,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '시작하기',
                        style: TextStyle(fontSize: 18),
                      ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
    );
  }

  String _getOptionDescription(int chapterCount) {
    switch (chapterCount) {
      case 1:
        return '가볍게 시작하기';
      case 2:
        return '적당한 학습량';
      case 3:
        return '집중 학습';
      default:
        return '';
    }
  }

  Future<void> _saveAndContinue() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final dao = ref.read(userSettingsDaoProvider);

      // 학습량 설정 저장
      await dao.setDailyGoal(_selectedChapterCount);

      // 온보딩 완료 기록
      await dao.completeOnboarding();

      // 최초 실행 기록
      await dao.recordFirstLaunch();

      // 메인 화면으로 이동
      widget.onComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정 저장 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
