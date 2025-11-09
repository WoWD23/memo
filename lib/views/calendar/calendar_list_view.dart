import 'package:flutter/material.dart';
import '../../models/check_in.dart';
import '../../models/pomodoro_record.dart';
import 'calendar_types.dart';

/// 列表视图组件
class CalendarListView extends StatefulWidget {
  final DateTime selectedMonth;
  final List<CheckIn> checkIns;
  final List<PomodoroRecord> pomodoroRecords;
  final Map<String, int> pomodoroCountByDate;
  final Map<String, int> todoCountByDate;
  final List<TodoTestData> testTodos;
  final ScrollController scrollController;

  const CalendarListView({
    super.key,
    required this.selectedMonth,
    required this.checkIns,
    required this.pomodoroRecords,
    required this.pomodoroCountByDate,
    required this.todoCountByDate,
    required this.testTodos,
    required this.scrollController,
  });

  @override
  State<CalendarListView> createState() => _CalendarListViewState();
}

class _CalendarListViewState extends State<CalendarListView> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // 默认选中今天
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 上半部分：日历视图
        Expanded(
          flex: 1,
          child: _buildCalendarSection(),
        ),
        const Divider(height: 1, thickness: 1),
        // 下半部分：事件列表
        Expanded(
          flex: 1,
          child: _buildEventListSection(),
        ),
      ],
    );
  }

  /// 构建日历区域（上半部分）
  Widget _buildCalendarSection() {
    // 生成前后各12个月的月份列表
    final months = <DateTime>[];
    for (int i = -12; i <= 12; i++) {
      months.add(DateTime(widget.selectedMonth.year, widget.selectedMonth.month + i, 1));
    }

    return ListView.builder(
      controller: widget.scrollController,
      itemCount: months.length,
      itemBuilder: (context, index) {
        final month = months[index];
        return _buildMonthSection(month);
      },
    );
  }

  /// 构建月份区域
  Widget _buildMonthSection(DateTime month) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${month.month}月',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        _buildWeekdayHeader(),
        _buildMonthGrid(month),
      ],
    );
  }

  /// 构建星期标题
  Widget _buildWeekdayHeader() {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建月份网格
  Widget _buildMonthGrid(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final weekdayOfFirstDay = firstDayOfMonth.weekday; // 1=Monday, 7=Sunday

    // 计算需要显示的周数
    final totalCells = daysInMonth + (weekdayOfFirstDay - 1);
    final weeks = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(weeks, (weekIndex) {
          return _buildWeek(month, weekIndex, weekdayOfFirstDay, daysInMonth);
        }),
      ),
    );
  }

  /// 构建一周
  Widget _buildWeek(DateTime month, int weekIndex, int weekdayOfFirstDay, int daysInMonth) {
    return Row(
      children: List.generate(7, (dayIndex) {
        final dayNumber = weekIndex * 7 + dayIndex + 1 - (weekdayOfFirstDay - 1);
        
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return Expanded(child: Container(height: 44));
        }

        final date = DateTime(month.year, month.month, dayNumber);
        return Expanded(
          child: _buildDayCell(date),
        );
      }),
    );
  }

  /// 构建日期单元格
  Widget _buildDayCell(DateTime date) {
    final dateKey = CalendarUtils.formatDateKey(date);
    final isToday = CalendarUtils.isToday(date);
    final isSelected = _selectedDate != null && CalendarUtils.isSameDay(date, _selectedDate!);
    
    // 检查是否有事件
    final hasCheckIn = (widget.checkIns.any((c) => CalendarUtils.isSameDay(c.date, date)));
    final hasPomodoroRecord = (widget.pomodoroCountByDate[dateKey] ?? 0) > 0;
    final hasTodoRecord = (widget.todoCountByDate[dateKey] ?? 0) > 0;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : (isToday ? Colors.red[50] : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.red : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasCheckIn) ...[
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 2),
                ],
                if (hasPomodoroRecord) ...[
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 2),
                ],
                if (hasTodoRecord)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建事件列表区域（下半部分）
  Widget _buildEventListSection() {
    if (_selectedDate == null) {
      return Center(
        child: Text(
          '请选择日期查看事件',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    final dateKey = CalendarUtils.formatDateKey(_selectedDate!);
    final events = _getEventsForDate(_selectedDate!);

    return Container(
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期标题
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              CalendarUtils.formatDateString(_selectedDate!),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 事件列表
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text(
                      '当日无事件',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(events[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 获取指定日期的所有事件
  List<_EventItem> _getEventsForDate(DateTime date) {
    final dateKey = CalendarUtils.formatDateKey(date);
    final events = <_EventItem>[];

    // 添加打卡事件
    for (final checkIn in widget.checkIns) {
      if (CalendarUtils.isSameDay(checkIn.date, date)) {
        events.add(_EventItem(
          type: EventType.checkIn,
          time: CalendarUtils.formatTime(checkIn.date),
          title: '每日打卡',
          color: Colors.green,
          icon: Icons.check_circle_outline,
        ));
      }
    }

    // 添加番茄钟事件
    for (final record in widget.pomodoroRecords) {
      if (CalendarUtils.isSameDay(record.startedAt, date)) {
        events.add(_EventItem(
          type: EventType.pomodoro,
          time: CalendarUtils.formatTime(record.startedAt),
          title: '专注时间',
          color: Colors.orange,
          icon: Icons.timer_outlined,
          duration: record.durationMinutes,
        ));
      }
    }

    // 添加待办事件
    for (final todo in widget.testTodos) {
      if (CalendarUtils.isSameDay(todo.startTime, date)) {
        events.add(_EventItem(
          type: EventType.todo,
          time: CalendarUtils.formatTime(todo.startTime),
          title: todo.title,
          color: Colors.blue,
          icon: Icons.check_box_outlined,
          duration: todo.durationMinutes,
          completed: todo.completed,
        ));
      }
    }

    // 按时间排序
    events.sort((a, b) => a.time.compareTo(b.time));

    return events;
  }

  /// 构建事件卡片
  Widget _buildEventCard(_EventItem event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 左侧颜色指示器和图标
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: event.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              event.icon,
              color: event.color,
              size: 24,
            ),
            const SizedBox(width: 12),
            // 中间内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: event.completed == true ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        event.time,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (event.duration != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${event.duration}分钟',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 事件项数据类
class _EventItem {
  final EventType type;
  final String time;
  final String title;
  final Color color;
  final IconData icon;
  final int? duration;
  final bool? completed;

  _EventItem({
    required this.type,
    required this.time,
    required this.title,
    required this.color,
    required this.icon,
    this.duration,
    this.completed,
  });
}

