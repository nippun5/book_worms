import 'package:flutter/material.dart';

/// Brown & white palette shared by the app UI and the store-listing assets.
class AppColors {
  AppColors._();

  static const brown900 = Color(0xFF3E2723);
  static const brown700 = Color(0xFF5D4037);
  static const brown500 = Color(0xFF6B4A32); // primary
  static const brown300 = Color(0xFFA9784F);
  static const tan100 = Color(0xFFF1E4D3);
  static const cream50 = Color(0xFFFFFBF6);
  static const gold = Color(0xFFD9A441);
  static const grayText = Color(0xFF93826F);
  static const green = Color(0xFF6B8F71);
  static const red = Color(0xFFB3574B);

  static const accents = <Color>[
    Color(0xFFB5654A), // terracotta
    Color(0xFF7C9473), // sage
    Color(0xFF6E8AA3), // dusty blue
    Color(0xFFC9A227), // mustard
    Color(0xFF8B5E7A), // plum
    Color(0xFF5D7A8C), // slate
  ];

  static Color accentFor(int seed) => accents[seed.abs() % accents.length];
}
