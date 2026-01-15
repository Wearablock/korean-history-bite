import 'package:flutter/material.dart';

class Era {
  final String id;
  final int order;
  final Map<String, String> name;
  final Map<String, String>? description;
  final String? color;

  const Era({
    required this.id,
    required this.order,
    required this.name,
    this.description,
    this.color,
  });

  factory Era.fromJson(Map<String, dynamic> json) {
    return Era(
      id: json['id'] as String,
      order: json['order'] as int,
      name: Map<String, String>.from(json['name'] as Map),
      description: json['description'] != null
          ? Map<String, String>.from(json['description'] as Map)
          : null,
      color: json['color'] as String?,
    );
  }

  /// 현재 로케일에 맞는 이름 반환
  /// fallback: en -> ko
  String getName(String locale) {
    return name[locale] ?? name['en'] ?? name['ko'] ?? id;
  }

  /// 현재 로케일에 맞는 설명 반환
  String? getDescription(String locale) {
    if (description == null) return null;
    return description![locale] ?? description!['en'] ?? description!['ko'];
  }

  /// 색상 파싱 (hex string -> Color)
  Color? get themeColor {
    if (color == null) return null;
    final hex = color!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
