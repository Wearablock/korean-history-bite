import 'package:flutter/material.dart';

/// 앱 색상 정의 (단청 톤)
class AppColors {
  AppColors._();

  // ============================================================
  // Primary - 감색 (딥 네이비)
  // ============================================================

  static const Color primary = Color(0xFF2C3E50);
  static const Color primaryLight = Color(0xFF3D566E);
  static const Color primaryDark = Color(0xFF1A252F);

  // ============================================================
  // Secondary - 주황 (단청)
  // ============================================================

  static const Color secondary = Color(0xFFE67E22);
  static const Color secondaryLight = Color(0xFFF39C4D);
  static const Color secondaryDark = Color(0xFFBA6418);

  // ============================================================
  // Accent - 청록 (비취)
  // ============================================================

  static const Color accent = Color(0xFF1ABC9C);
  static const Color accentLight = Color(0xFF48D1B5);
  static const Color accentDark = Color(0xFF16A085);

  // ============================================================
  // Semantic Colors
  // ============================================================

  /// 정답
  static const Color correct = Color(0xFF27AE60);
  static const Color correctLight = Color(0xFFD5F4E2);

  /// 오답
  static const Color wrong = Color(0xFFE74C3C);
  static const Color wrongLight = Color(0xFFFDEDEB);

  /// 경고
  static const Color warning = Color(0xFFF39C12);

  /// 정보
  static const Color info = Color(0xFF3498DB);

  // ============================================================
  // Traditional Sign (간판)
  // ============================================================

  static const Color signBorder = Color(0xFF5D4037); // 갈색 테두리
  static const Color signBackground = Color(0xFFFFFDF5); // 약간 따뜻한 흰색

  // ============================================================
  // Neutral Colors
  // ============================================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Grey Scale (Material Design grey 기준)
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);

  // Light Mode
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF2C3E50);
  static const Color textSecondaryLight = Color(0xFF7F8C8D);
  static const Color dividerLight = Color(0xFFECF0F1);

  // Dark Mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFECF0F1);
  static const Color textSecondaryDark = Color(0xFF95A5A6);
  static const Color dividerDark = Color(0xFF2C3E50);

  // ============================================================
  // 학습 카테고리 색상 (시대별)
  // ============================================================

  static const Color eraPrehistoric = Color(0xFF8D6E63);    // 선사시대
  static const Color eraGojoseon = Color(0xFF795548);       // 고조선
  static const Color eraThreeKingdoms = Color(0xFF5C6BC0);  // 삼국시대
  static const Color eraUnifiedSilla = Color(0xFF26A69A);   // 통일신라
  static const Color eraGoryeo = Color(0xFF42A5F5);         // 고려
  static const Color eraJoseon = Color(0xFFAB47BC);         // 조선
  static const Color eraModern = Color(0xFFEF5350);         // 근현대

  // ============================================================
  // Progress Colors
  // ============================================================

  static const Color progressNew = Color(0xFF3498DB);       // 신규
  static const Color progressLearning = Color(0xFFF39C12);  // 학습중
  static const Color progressReview = Color(0xFF9B59B6);    // 복습
  static const Color progressMastered = Color(0xFF27AE60);  // 완전습득
}
