import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// 사운드 효과 타입 정의
enum SoundEffect {
  /// 정답 시
  correct,

  /// 오답 시
  wrong,
}

/// 사운드 재생 서비스
///
/// Singleton 패턴으로 전역에서 동일 인스턴스 사용
class SoundService {
  // Singleton 인스턴스
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  // AudioPlayer 인스턴스
  final AudioPlayer _player = AudioPlayer();

  // 활성화 상태 (설정에서 제어)
  bool _enabled = true;

  /// 사운드 활성화/비활성화 설정
  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) {
      _player.stop(); // 비활성화 시 재생 중인 사운드 정지
    }
  }

  /// 현재 활성화 상태 반환
  bool get isEnabled => _enabled;

  /// 사운드 효과 재생
  Future<void> play(SoundEffect effect) async {
    if (!_enabled) return;

    // 효과음 파일 경로 매핑
    final assetPath = switch (effect) {
      SoundEffect.correct => 'sounds/correct.mp3',
      SoundEffect.wrong => 'sounds/wrong.mp3',
    };

    try {
      // 이전 재생 정지 후 새 사운드 재생
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('[SoundService] 사운드 재생 실패: $e');
    }
  }

  /// 볼륨 설정 (0.0 ~ 1.0)
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// 리소스 해제
  void dispose() {
    _player.dispose();
  }
}
