import 'package:flutter/material.dart';

/// 应用颜色定义
class AppColors {
  AppColors._();

  // 主色调（紫色系，符合设计图）
  static const Color primary = Color(0xFF9C27B0); // Purple 500
  static const Color primaryDark = Color(0xFF7B1FA2); // Purple 700
  static const Color primaryLight = Color(0xFFBA68C8); // Purple 300
  static const Color primaryVeryLight = Color(0xFFE1BEE7); // Purple 100
  
  // 粉红色（用于AM按钮选中状态）
  static const Color pink = Color(0xFFE91E63); // Pink 500
  static const Color pinkLight = Color(0xFFF8BBD0); // Pink 200

  // 功能色
  static const Color checkIn = Color(0xFF4CAF50); // 打卡-绿色
  static const Color pomodoro = Color(0xFFF44336); // 番茄钟-红色
  static const Color pomodoroWork = Color(0xFFF44336); // 工作模式-红色
  static const Color pomodoroShortBreak = Color(0xFF4CAF50); // 短休息-绿色
  static const Color pomodoroLongBreak = Color(0xFF2196F3); // 长休息-蓝色

  // 警告和信息色
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // 中性色（浅色模式）
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color background = Color(0xFFFFFFFF);

  // 中性色（深色模式）
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color dividerDark = Color(0xFF424242);
  static const Color backgroundDark = Color(0xFF121212);

  // Tab导航颜色
  static const Color tabSelected = primary;
  static const Color tabUnselected = Color(0xFF9E9E9E);
}

