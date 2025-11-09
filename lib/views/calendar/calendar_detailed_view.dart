import 'package:flutter/material.dart';
import '../../models/check_in.dart';
import '../../models/pomodoro_record.dart';
import 'calendar_types.dart';

/// 详细信息视图组件
class CalendarDetailedView extends StatelessWidget {
  final DateTime selectedMonth;
  final List<CheckIn> checkIns;
  final List<PomodoroRecord> pomodoroRecords;
  final Map<String, int> pomodoroCountByDate;
  final Map<String, int> todoCountByDate;
  final List<TodoTestData> testTodos;
  final ScrollController scrollController;
  final Function(DateTime date) onDateSelected;

  const CalendarDetailedView({
    super.key,
    required this.selectedMonth,
    required this.checkIns,
    required this.pomodoroRecords,
    required this.pomodoroCountByDate,
    required this.todoCountByDate,
    required this.testTodos,
    required this.scrollController,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 生成前后各12个月的月份列表
    final months = <DateTime>[];
    for (int i = -12; i <= 12; i++) {
      months.add(DateTime(selectedMonth.year, selectedMonth.month + i, 1));
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: months.length,
      itemBuilder: (context, index) {
        final month = months[index];
        return _buildDetailedMonthSection(month);
      },
    );
  }

  /// 构建详细信息模式的月份区域
  Widget _buildDetailedMonthSection(DateTime month) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            '${month.month}月',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        _buildWeekdayHeader(),
        _buildDetailedMonthGrid(month),
      ],
    );
  }

  /// 星期标题
  Widget _buildWeekdayHeader() {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建详细信息模式的月份网格
  Widget _buildDetailedMonthGrid(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday;

    final totalDays = daysInMonth + weekdayOfFirstDay - 1;
    final weeks = (totalDays / 7).ceil();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: List.generate(weeks, (weekIndex) {
          return _buildDetailedWeek(month, weekIndex, weekdayOfFirstDay, daysInMonth);
        }),
      ),
    );
  }

  /// 构建详细信息模式的一周
  Widget _buildDetailedWeek(DateTime month, int weekIndex, int weekdayOfFirstDay, int daysInMonth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (dayIndex) {
        final cellIndex = weekIndex * 7 + dayIndex;
        final dayNumber = cellIndex - weekdayOfFirstDay + 2;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return Expanded(child: Container(height: 80));
        }

        final date = DateTime(month.year, month.month, dayNumber);
        return Expanded(
          child: SizedBox(
            height: 80, // 每个日期格子固定高度（足够容纳日期+3个事件项）
            child: _buildDetailedDayCell(date),
          ),
        );
      }),
    );
  }

  /// 构建详细信息模式的日期单元格
  Widget _buildDetailedDayCell(DateTime date) {
    final dateKey = CalendarUtils.formatDateKey(date);
    final isToday = CalendarUtils.isToday(date);
    final isWeekend = date.weekday == 6 || date.weekday == 7;

    // 获取当天的事件
    final dayEvents = _getDayEvents(date, dateKey);

    return GestureDetector(
      onTap: () => onDateSelected(date),
      child: ClipRect(
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isToday ? Colors.red[50] : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 日期数字
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday
                        ? Colors.red
                        : isWeekend
                            ? Colors.grey[400]
                            : Colors.black87,
                  ),
                ),
              ),
              // 事件列表（最多显示2个事件 + 1个"+n"提示）
              ..._buildLimitedEventItems(dayEvents),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建限制数量的事件项列表
  List<Widget> _buildLimitedEventItems(List<_DayEvent> events) {
    if (events.isEmpty) {
      return [];
    }
    
    // 1-3个事件：全部显示
    if (events.length <= 3) {
      return events.map((event) => _buildEventItem(event)).toList();
    }
    
    // 超过3个事件：显示前2个 + "+n"提示
    final displayEvents = events.take(2).map((event) => _buildEventItem(event)).toList();
    final remainingCount = events.length - 2;
    
    displayEvents.add(
      Container(
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        child: Text(
          '+$remainingCount',
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
    
    return displayEvents;
  }

  /// 获取指定日期的所有事件
  List<_DayEvent> _getDayEvents(DateTime date, String dateKey) {
    final events = <_DayEvent>[];

    // 添加打卡事件
    final hasCheckIn = checkIns.any((c) => CalendarUtils.formatDateKey(c.date) == dateKey);
    if (hasCheckIn) {
      events.add(_DayEvent(
        type: EventType.checkIn,
        title: '打卡',
        time: null,
        color: Colors.green,
      ));
    }

    // 添加番茄钟事件
    final dayPomodoros = pomodoroRecords
        .where((p) => CalendarUtils.formatDateKey(p.startedAt) == dateKey && p.completed && p.mode == 'work')
        .toList();
    
    for (var pomodoro in dayPomodoros) {
      final time = CalendarUtils.formatTime(pomodoro.startedAt);
      events.add(_DayEvent(
        type: EventType.pomodoro,
        title: '番茄钟 ${pomodoro.durationMinutes}分钟',
        time: time,
        color: Colors.orange,
      ));
    }

    // 添加待办事项
    final dayTodos = testTodos
        .where((todo) => CalendarUtils.formatDateKey(todo.startTime) == dateKey)
        .toList();
    
    for (var todo in dayTodos) {
      final time = CalendarUtils.formatTime(todo.startTime);
      events.add(_DayEvent(
        type: EventType.todo,
        title: todo.title,
        time: time,
        color: Colors.blue,
      ));
    }

    // 按时间排序
    events.sort((a, b) {
      if (a.time == null && b.time == null) return 0;
      if (a.time == null) return -1;
      if (b.time == null) return 1;
      return a.time!.compareTo(b.time!);
    });

    return events;
  }

  /// 构建事件项
  Widget _buildEventItem(_DayEvent event) {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4, bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
        border: Border(
          left: BorderSide(
            color: event.color,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          if (event.time != null) ...[
            Text(
              event.time!,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              event.title,
              style: TextStyle(
                fontSize: 10,
                color: event.color.withOpacity(0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // 超出显示省略号
            ),
          ),
        ],
      ),
    );
  }
}

/// 日事件数据类
class _DayEvent {
  final EventType type;
  final String title;
  final String? time;
  final Color color;

  _DayEvent({
    required this.type,
    required this.title,
    required this.time,
    required this.color,
  });
}

