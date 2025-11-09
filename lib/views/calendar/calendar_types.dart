import 'package:flutter/material.dart';

/// 日历视图模式
enum CalendarViewMode {
  compact,        // 紧凑
  stacked,        // 叠放
  detailed,       // 详细信息
  list,           // 列表
}

/// 日历展开状态（仅用于紧凑模式）
enum CalendarDisplayState {
  collapsed,      // 折叠：显示月历视图
  expanded,       // 展开：显示日详情视图
}

/// 事件类型枚举
enum EventType {
  checkIn,    // 打卡
  pomodoro,   // 番茄钟
  todo,       // 待办
}

/// 测试用的待办数据结构
class TodoTestData {
  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final bool completed;
  
  TodoTestData({
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    required this.completed,
  });
}

/// 日历工具类
class CalendarUtils {
  /// 格式化日期为key（YYYY-MM-DD）
  static String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化日期字符串
  static String formatDateString(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}年${date.month}月${date.day}日 - $weekday';
  }

  /// 格式化农历日期（简化版）
  static String formatLunarDate(DateTime date) {
    // TODO: 接入真实的农历计算
    return '乙巳年九月十八';
  }

  /// 格式化时间
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 获取星期缩写
  static String getWeekdayShort(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return weekdays[weekday - 1];
  }

  /// 判断是否为今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 判断是否为同一天
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

