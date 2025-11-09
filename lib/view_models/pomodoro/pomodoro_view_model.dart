import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../repositories/pomodoro_repository.dart';
import '../../models/pomodoro_record.dart';
import '../../services/notification_service.dart';
import '../../services/calendar_service.dart';

/// 番茄钟模式
enum PomodoroMode {
  work, // 工作模式
  shortBreak, // 短休息
  longBreak, // 长休息
}

/// 番茄钟状态
enum PomodoroState {
  idle, // 空闲（未开始）
  running, // 运行中
  paused, // 暂停
  completed, // 完成
}

/// 番茄钟ViewModel
class PomodoroViewModel extends ChangeNotifier {
  final PomodoroRepository _repository = PomodoroRepository();
  final NotificationService _notificationService = NotificationService.instance;
  final CalendarService _calendarService = CalendarService();
  
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  Duration _totalDuration = Duration.zero;
  PomodoroMode _mode = PomodoroMode.work;
  PomodoroState _state = PomodoroState.idle;
  bool _isLocked = false; // 是否锁定（倒计时期间）
  int _completedPomodoros = 0; // 完成的番茄钟数量
  DateTime? _startedAt; // 开始时间

  // Getters
  Duration get remainingTime => _remainingTime;
  Duration get totalDuration => _totalDuration;
  PomodoroMode get mode => _mode;
  PomodoroState get state => _state;
  bool get isLocked => _isLocked;
  int get completedPomodoros => _completedPomodoros;

  /// 格式化时间显示（MM:SS）
  String get formattedTime {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 获取模式显示文本
  String get modeText {
    switch (_mode) {
      case PomodoroMode.work:
        return '工作模式';
      case PomodoroMode.shortBreak:
        return '短休息';
      case PomodoroMode.longBreak:
        return '长休息';
    }
  }

  /// 获取模式颜色
  int get modeColor {
    switch (_mode) {
      case PomodoroMode.work:
        return 0xFFF44336; // 红色
      case PomodoroMode.shortBreak:
        return 0xFF4CAF50; // 绿色
      case PomodoroMode.longBreak:
        return 0xFF2196F3; // 蓝色
    }
  }

  /// 开始倒计时（自定义时长）
  void startCountdown(Duration duration) {
    if (_state == PomodoroState.running) return;

    debugPrint('PomodoroViewModel.startCountdown: duration=$duration');
    
    // 限制最大时间为120分钟（2小时）
    final maxDuration = const Duration(minutes: 120);
    _totalDuration = duration > maxDuration ? maxDuration : duration;
    _remainingTime = _totalDuration;
    _state = PomodoroState.running;
    _isLocked = true; // 锁定界面
    _mode = PomodoroMode.work; // 默认工作模式
    _startedAt = DateTime.now(); // 记录开始时间

    debugPrint('PomodoroViewModel.startCountdown: state=$_state, remainingTime=$_remainingTime, totalTime=$_totalDuration');
    
    _startTimer();
    notifyListeners();
    
    debugPrint('PomodoroViewModel.startCountdown: notifyListeners called');
  }

  /// 开始标准番茄钟
  void startStandardPomodoro() {
    final duration = Duration(minutes: AppConstants.pomodoroWorkDuration);
    startCountdown(duration);
  }

  /// 暂停/继续
  void togglePause() {
    if (_state == PomodoroState.running) {
      _pause();
    } else if (_state == PomodoroState.paused) {
      _resume();
    }
  }

  /// 暂停
  void _pause() {
    _timer?.cancel();
    _state = PomodoroState.paused;
    notifyListeners();
  }

  /// 继续
  void _resume() {
    if (_remainingTime.inSeconds > 0) {
      _state = PomodoroState.running;
      _startTimer();
      notifyListeners();
    }
  }

  /// 取消倒计时
  void cancel() {
    // 保存未完成的记录
    if (_startedAt != null && _mode == PomodoroMode.work) {
      _saveRecord(completed: false);
    }
    
    _timer?.cancel();
    _timer = null;
    _remainingTime = Duration.zero;
    _totalDuration = Duration.zero;
    _state = PomodoroState.idle;
    _isLocked = false; // 解锁界面
    _startedAt = null;
    notifyListeners();
  }

  /// 跳过当前倒计时
  void skip() {
    _timer?.cancel();
    _remainingTime = Duration.zero;
    _onCompleted();
  }

  /// 重置倒计时
  void reset() {
    _timer?.cancel();
    _remainingTime = _totalDuration;
    _state = PomodoroState.running;
    _startTimer();
    notifyListeners();
  }

  /// 启动定时器
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        notifyListeners();
      } else {
        _onCompleted();
      }
    });
  }

  /// 倒计时完成
  void _onCompleted() {
    _timer?.cancel();
    _state = PomodoroState.completed;

    if (_mode == PomodoroMode.work) {
      // 保存完成的工作记录
      _saveRecord(completed: true);
      
      // 显示番茄钟完成通知
      _notificationService.showPomodoroCompleteNotification();
      
      _completedPomodoros++;
      // 每4个工作后进入长休息
      if (_completedPomodoros % AppConstants.pomodorosUntilLongBreak == 0) {
        _mode = PomodoroMode.longBreak;
        _remainingTime = Duration(minutes: AppConstants.pomodoroLongBreakDuration);
      } else {
        _mode = PomodoroMode.shortBreak;
        _remainingTime = Duration(minutes: AppConstants.pomodoroShortBreakDuration);
      }
      
      // 重置开始时间
      _startedAt = DateTime.now();
      
      // 自动开始休息倒计时
      _state = PomodoroState.running;
      _startTimer();
    } else {
      // 保存完成的休息记录
      _saveRecord(completed: true);
      
      // 显示休息结束通知
      _notificationService.showBreakEndNotification();
      
      // 休息结束，回到工作模式
      _mode = PomodoroMode.work;
      _isLocked = false; // 解锁界面
      _startedAt = null;
    }

    notifyListeners();
  }
  
  /// 保存番茄钟记录到数据库
  Future<void> _saveRecord({required bool completed}) async {
    if (_startedAt == null) return;
    
    try {
      final record = PomodoroRecord(
        durationMinutes: _totalDuration.inMinutes,
        mode: _modeToString(_mode),
        completed: completed,
        startedAt: _startedAt!,
        endedAt: DateTime.now(),
      );
      
      final savedRecord = await _repository.create(record);
      debugPrint('番茄钟记录已保存: mode=$_mode, completed=$completed, duration=${_totalDuration.inMinutes}分钟');

      // 只同步工作模式的完成记录到日历
      if (_mode == PomodoroMode.work && completed && savedRecord != null) {
        await _syncToCalendarIfEnabled(savedRecord);
      }
    } catch (e) {
      debugPrint('保存番茄钟记录失败: $e');
    }
  }

  /// 如果开启了日历同步，将番茄钟记录同步到系统日历
  Future<void> _syncToCalendarIfEnabled(PomodoroRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncEnabled = prefs.getBool('sync_to_calendar') ?? false;
      
      if (syncEnabled) {
        final success = await _calendarService.addPomodoroEvent(record);
        if (success) {
          debugPrint('番茄钟记录已同步到系统日历');
        } else {
          debugPrint('番茄钟记录同步到系统日历失败');
        }
      }
    } catch (e) {
      debugPrint('同步到日历时出错: $e');
    }
  }
  
  /// 将模式转换为字符串
  String _modeToString(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.work:
        return 'work';
      case PomodoroMode.shortBreak:
        return 'shortBreak';
      case PomodoroMode.longBreak:
        return 'longBreak';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

