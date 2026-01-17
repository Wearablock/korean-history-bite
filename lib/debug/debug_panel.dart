// lib/debug/debug_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/debug_utils.dart';
import '../core/theme/app_colors.dart';
import '../data/providers/database_providers.dart';

/// 디버그 패널
/// 개발 모드에서만 표시되는 디버그 도구
class DebugPanel extends ConsumerStatefulWidget {
  final VoidCallback? onRefresh;

  const DebugPanel({
    super.key,
    this.onRefresh,
  });

  @override
  ConsumerState<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends ConsumerState<DebugPanel> {
  String _debugLog = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.orange.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(
                  Icons.bug_report,
                  color: Colors.orange[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '디버그 패널',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 현재 시간 상태
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    DebugUtils.isTimeOverridden
                        ? Icons.warning
                        : Icons.check_circle,
                    color: DebugUtils.isTimeOverridden
                        ? AppColors.warning
                        : AppColors.correct,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DebugUtils.debugInfo,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 시간 점프 버튼들
            Text(
              '시간 점프',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildJumpButton('1일 후', 1),
                _buildJumpButton('3일 후', 3),
                _buildJumpButton('7일 후', 7),
                _buildJumpButton('14일 후', 14),
                _buildJumpButton('30일 후', 30),
              ],
            ),

            const SizedBox(height: 12),

            // 리셋 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetTime,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('시간 리셋'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[400]!),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // DB 상태 확인 버튼
            Text(
              'DB 상태 확인',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkDbState,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.storage, size: 16),
                label: const Text('복습 대상 조회'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            // 디버그 로그 표시
            if (_debugLog.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    _debugLog,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJumpButton(String label, int days) {
    return ElevatedButton(
      onPressed: () => _jumpDays(days),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }

  void _jumpDays(int days) {
    DebugUtils.jumpDays(days);
    setState(() {});
    widget.onRefresh?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$days일 후로 시간 이동'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _resetTime() {
    DebugUtils.resetTime();
    setState(() {});
    widget.onRefresh?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('실제 시간으로 복귀'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _checkDbState() async {
    setState(() {
      _isLoading = true;
      _debugLog = '';
    });

    try {
      final db = ref.read(appDatabaseProvider);
      final now = DebugUtils.now;
      final startOfDay = DateTime(now.year, now.month, now.day);

      // 복습 대상 조회 (DAO 메서드 사용)
      final reviewDue = await db.studyRecordsDao.getReviewQuestions(limit: 1000);
      final allRecords = await db.studyRecordsDao.getAllRecords();

      // 레벨 0 (오답 복습)과 레벨 1+ (망각곡선 복습) 분리
      final wrongReview = reviewDue.where((r) => r.level == 0).toList();
      final spacedReview = reviewDue.where((r) => r.level > 0).toList();

      final buffer = StringBuffer();
      buffer.writeln('=== 디버그 시간: ${now.toString().substring(0, 19)} ===');
      buffer.writeln('=== 오늘 시작: ${startOfDay.toString().substring(0, 19)} ===');
      buffer.writeln('');
      buffer.writeln('========================================');
      buffer.writeln('총 복습 대상: ${reviewDue.length}개');
      buffer.writeln('  - 오답 복습 (레벨 0): ${wrongReview.length}개');
      buffer.writeln('  - 망각곡선 복습 (레벨 1+): ${spacedReview.length}개');
      buffer.writeln('========================================');
      buffer.writeln('');
      buffer.writeln('--- 오답 복습 대상 (레벨 0) ---');
      for (final r in wrongReview) {
        buffer.writeln('  ${r.questionId}');
        buffer.writeln('    level: ${r.level}');
        buffer.writeln('    nextReviewAt: ${r.nextReviewAt?.toString().substring(0, 19) ?? "null"}');
        buffer.writeln('    lastStudiedAt: ${r.lastStudiedAt?.toString().substring(0, 19) ?? "null"}');
      }
      buffer.writeln('');
      buffer.writeln('--- 망각곡선 복습 대상 (레벨 1+) ---');
      for (final r in spacedReview) {
        buffer.writeln('  ${r.questionId}');
        buffer.writeln('    level: ${r.level}');
        buffer.writeln('    nextReviewAt: ${r.nextReviewAt?.toString().substring(0, 19) ?? "null"}');
        buffer.writeln('    lastStudiedAt: ${r.lastStudiedAt?.toString().substring(0, 19) ?? "null"}');
      }
      buffer.writeln('');
      buffer.writeln('--- 전체 학습 기록 (${allRecords.length}개) ---');
      for (final r in allRecords) {
        final isInReviewDue = reviewDue.any((due) => due.questionId == r.questionId);
        final nextStr = r.nextReviewAt?.toString().substring(0, 19) ?? 'null';
        final dueLabel = isInReviewDue ? (r.level == 0 ? '[WRONG_DUE]' : '[SPACED_DUE]') : '';
        buffer.writeln('  ${r.questionId}: lv${r.level}, next=$nextStr $dueLabel');
      }

      setState(() {
        _debugLog = buffer.toString();
      });
    } catch (e) {
      setState(() {
        _debugLog = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
