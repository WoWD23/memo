import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/check_in.dart';
import '../models/pomodoro_record.dart';
import '../models/todo.dart';

/// 系统日历集成服务
/// 
/// 功能：
/// - 同步打卡记录到系统日历
/// - 同步番茄钟记录到系统日历
/// - 同步待办事项到系统日历
/// - 管理日历权限
class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  String? _selectedCalendarId; // 缓存选中的日历ID

  /// 请求日历访问权限
  /// 
  /// 返回 true 表示权限已授予
  Future<bool> requestPermissions() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
          return false;
        }
      }
      
      return permissionsGranted.isSuccess && permissionsGranted.data!;
    } catch (e) {
      print('Error requesting calendar permissions: $e');
      return false;
    }
  }

  /// 检查是否已有权限
  Future<bool> hasPermissions() async {
    try {
      final result = await _deviceCalendarPlugin.hasPermissions();
      return result.isSuccess && result.data!;
    } catch (e) {
      print('Error checking calendar permissions: $e');
      return false;
    }
  }

  /// 获取设备上所有可用的日历
  Future<List<Calendar>> getCalendars() async {
    try {
      final hasPermission = await hasPermissions();
      if (!hasPermission) {
        return [];
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      return calendarsResult.data ?? [];
    } catch (e) {
      print('Error retrieving calendars: $e');
      return [];
    }
  }

  /// 获取或创建 Memo 专用日历
  /// 
  /// 如果设备上没有 Memo 日历，则创建一个
  Future<String?> getOrCreateMemoCalendar() async {
    try {
      if (_selectedCalendarId != null) {
        return _selectedCalendarId;
      }

      final calendars = await getCalendars();
      
      // 查找名为 "Memo" 的日历
      final memoCalendar = calendars.where((cal) => 
        cal.name == 'Memo' && cal.isReadOnly == false
      ).firstOrNull;

      if (memoCalendar != null) {
        _selectedCalendarId = memoCalendar.id;
        return _selectedCalendarId;
      }

      // 如果没有找到，使用第一个可写日历
      final writeableCalendar = calendars.where((cal) => 
        cal.isReadOnly == false
      ).firstOrNull;

      if (writeableCalendar != null) {
        _selectedCalendarId = writeableCalendar.id;
        return _selectedCalendarId;
      }

      // 如果都没有，返回第一个日历
      if (calendars.isNotEmpty) {
        _selectedCalendarId = calendars.first.id;
        return _selectedCalendarId;
      }

      return null;
    } catch (e) {
      print('Error getting or creating Memo calendar: $e');
      return null;
    }
  }

  /// 添加打卡记录到日历
  /// 
  /// 在系统日历中创建一个全天事件，标记当天的打卡
  Future<bool> addCheckInEvent(CheckIn checkIn) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('Calendar permission not granted');
        return false;
      }

      final calendarId = await getOrCreateMemoCalendar();
      if (calendarId == null) {
        print('No calendar available');
        return false;
      }

      // 创建全天事件
      final checkInDate = checkIn.date;
      final startOfDay = DateTime(
        checkInDate.year,
        checkInDate.month,
        checkInDate.day,
      );

      final event = Event(
        calendarId,
        title: '📍 每日打卡',
        description: checkIn.note != null && checkIn.note!.isNotEmpty
            ? '打卡备注：${checkIn.note}'
            : '今日打卡完成',
        start: tz.TZDateTime.from(startOfDay, tz.local),
        end: tz.TZDateTime.from(startOfDay.add(const Duration(days: 1)), tz.local),
        allDay: true,
      );

      final createResult = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      return createResult?.isSuccess ?? false;
    } catch (e) {
      print('Error adding check-in event to calendar: $e');
      return false;
    }
  }

  /// 添加番茄钟记录到日历
  /// 
  /// 在系统日历中创建一个定时事件，显示专注时段
  Future<bool> addPomodoroEvent(PomodoroRecord record) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('Calendar permission not granted');
        return false;
      }

      final calendarId = await getOrCreateMemoCalendar();
      if (calendarId == null) {
        print('No calendar available');
        return false;
      }

      final durationMinutes = record.durationMinutes;
      final endTime = record.startedAt.add(Duration(minutes: durationMinutes));

      // 根据番茄钟时长选择图标
      String icon = '🍅';
      if (durationMinutes >= 90) {
        icon = '🔥'; // 长时间专注
      } else if (durationMinutes >= 60) {
        icon = '⚡'; // 中长时间专注
      }

      final event = Event(
        calendarId,
        title: '$icon 专注时间 ($durationMinutes分钟)',
        description: '完成了 $durationMinutes 分钟的专注工作',
        start: tz.TZDateTime.from(record.startedAt, tz.local),
        end: tz.TZDateTime.from(endTime, tz.local),
        allDay: false,
      );

      final createResult = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      return createResult?.isSuccess ?? false;
    } catch (e) {
      print('Error adding pomodoro event to calendar: $e');
      return false;
    }
  }

  /// 添加待办事项到日历
  /// 
  /// 在系统日历中创建一个事件，并设置提醒
  Future<bool> addTodoEvent(Todo todo) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('Calendar permission not granted');
        return false;
      }

      final calendarId = await getOrCreateMemoCalendar();
      if (calendarId == null) {
        print('No calendar available');
        return false;
      }

      // 如果没有到期日期，使用创建日期
      final dueDate = todo.dueDate ?? todo.createdAt;
      final startDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
      final endDate = startDate.add(const Duration(hours: 1));

      // 优先级图标
      String priorityIcon = '';
      switch (todo.priority) {
        case 2:
          priorityIcon = '🔴 '; // 高优先级
          break;
        case 1:
          priorityIcon = '🟡 '; // 中优先级
          break;
        case 0:
          priorityIcon = '🟢 '; // 低优先级
          break;
      }

      // 设置提醒（到期前一天）
      final reminders = todo.dueDate != null && !todo.completed
          ? [Reminder(minutes: 24 * 60)] // 提前一天提醒
          : null;

      final event = Event(
        calendarId,
        title: '$priorityIcon✅ ${todo.title}',
        description: todo.description != null && todo.description!.isNotEmpty
            ? todo.description!
            : '待办事项',
        start: tz.TZDateTime.from(startDate, tz.local),
        end: tz.TZDateTime.from(endDate, tz.local),
        allDay: todo.dueDate != null,
        reminders: reminders,
      );

      final createResult = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      return createResult?.isSuccess ?? false;
    } catch (e) {
      print('Error adding todo event to calendar: $e');
      return false;
    }
  }

  /// 批量添加打卡记录到日历
  Future<int> batchAddCheckInEvents(List<CheckIn> checkIns) async {
    int successCount = 0;
    for (final checkIn in checkIns) {
      final success = await addCheckInEvent(checkIn);
      if (success) successCount++;
      
      // 避免请求过快
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return successCount;
  }

  /// 批量添加番茄钟记录到日历
  Future<int> batchAddPomodoroEvents(List<PomodoroRecord> records) async {
    int successCount = 0;
    for (final record in records) {
      final success = await addPomodoroEvent(record);
      if (success) successCount++;
      
      // 避免请求过快
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return successCount;
  }

  /// 清除缓存的日历ID
  void clearCache() {
    _selectedCalendarId = null;
  }
}

