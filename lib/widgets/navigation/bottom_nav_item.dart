import 'package:flutter/material.dart';

/// 底部导航栏Tab项数据模型
class BottomNavItem {
  final String label;
  final IconData icon;
  final String route;

  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// 底部导航栏配置
class BottomNavConfig {
  BottomNavConfig._();

  static const List<BottomNavItem> items = [
    BottomNavItem(
      label: 'focast',
      icon: Icons.star, // 使用star作为标识，实际会使用自定义StarIcon
      route: '/pomodoro',
    ),
    BottomNavItem(
      label: 'calendar',
      icon: Icons.star,
      route: '/calendar',
    ),
    BottomNavItem(
      label: 'Home',
      icon: Icons.star,
      route: '/home',
    ),
    BottomNavItem(
      label: 'TODO',
      icon: Icons.star,
      route: '/todo',
    ),
    BottomNavItem(
      label: 'setting',
      icon: Icons.star,
      route: '/settings',
    ),
  ];
}

