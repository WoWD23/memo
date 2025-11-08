/// 应用常量定义
class AppConstants {
  AppConstants._();

  // 应用信息
  static const String appName = 'Memo';
  static const String appVersion = '1.0.0';

  // 番茄钟默认时长（分钟）
  static const int pomodoroWorkDuration = 25;
  static const int pomodoroShortBreakDuration = 5;
  static const int pomodoroLongBreakDuration = 15;
  static const int pomodorosUntilLongBreak = 4;
  
  // 时钟盘设置
  static const int maxCountdownMinutes = 120; // 最大倒计时时间：2小时（120分钟）
  static const int clockCircleMinutes = 120; // 时钟盘一圈对应的分钟数：2小时

  // 数据库
  static const String databaseName = 'memo.db';
  static const int databaseVersion = 1;

  // SharedPreferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyPomodoroWorkDuration = 'pomodoro_work_duration';
  static const String keyPomodoroShortBreakDuration =
      'pomodoro_short_break_duration';
  static const String keyPomodoroLongBreakDuration =
      'pomodoro_long_break_duration';
}

