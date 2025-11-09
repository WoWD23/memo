import 'package:flutter/material.dart';
import '../../models/check_in.dart';
import '../../models/pomodoro_record.dart';
import '../../core/theme/app_colors.dart';
import 'calendar_types.dart';

/// 紧凑视图组件
class CalendarCompactView extends StatelessWidget {
  final DateTime selectedMonth;
  final DateTime? selectedDate;
  final CalendarDisplayState displayState;
  final List<CheckIn> checkIns;
  final List<PomodoroRecord> pomodoroRecords;
  final Map<String, int> pomodoroCountByDate;
  final Map<String, int> todoCountByDate;
  final List<TodoTestData> testTodos;
  final ScrollController scrollController;
  final Function(DateTime date) onDateSelected;
  final VoidCallback onBack;

  const CalendarCompactView({
    super.key,
    required this.selectedMonth,
    required this.selectedDate,
    required this.displayState,
    required this.checkIns,
    required this.pomodoroRecords,
    required this.pomodoroCountByDate,
    required this.todoCountByDate,
    required this.testTodos,
    required this.scrollController,
    required this.onDateSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: displayState == CalendarDisplayState.expanded && selectedDate != null
          ? _buildDayDetailView(selectedDate!)
          : _buildCompactMonthView(),
    );
  }

  /// 紧凑月视图（可纵向滚动多个月份）
  Widget _buildCompactMonthView() {
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
        return _buildMonthSection(month);
      },
    );
  }

  /// 构建单个月份区域
  Widget _buildMonthSection(DateTime month) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 月份标题
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
        
        // 星期标题
        _buildWeekdayHeader(),
        
        // 日历网格
        _buildMonthGrid(month),
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

  /// 构建单个月份的日历网格
  Widget _buildMonthGrid(DateTime month) {
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
          return Row(
            children: List.generate(7, (dayIndex) {
              final cellIndex = weekIndex * 7 + dayIndex;
              final dayNumber = cellIndex - weekdayOfFirstDay + 2;
              
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Expanded(child: Container(height: 50));
              }

              final date = DateTime(month.year, month.month, dayNumber);
              return Expanded(
                child: _buildCompactDayCell(date),
              );
            }),
          );
        }),
      ),
    );
  }

  /// 紧凑模式的日期单元格
  Widget _buildCompactDayCell(DateTime date) {
    final dateKey = CalendarUtils.formatDateKey(date);
    final hasCheckIn = checkIns.any((c) => CalendarUtils.formatDateKey(c.date) == dateKey);
    final pomodoroCount = pomodoroCountByDate[dateKey] ?? 0;
    final todoCount = todoCountByDate[dateKey] ?? 0;
    final isToday = CalendarUtils.isToday(date);
    final isWeekend = date.weekday == 6 || date.weekday == 7;
    final hasEvents = hasCheckIn || pomodoroCount > 0 || todoCount > 0;

    return GestureDetector(
      onTap: () => onDateSelected(date),
      child: Container(
        height: 50,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday ? Colors.red : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday
                    ? Colors.white
                    : isWeekend
                        ? Colors.grey[400]
                        : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            if (hasEvents)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasCheckIn)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isToday ? Colors.white : Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (pomodoroCount > 0)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isToday ? Colors.white : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (todoCount > 0)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isToday ? Colors.white : Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  /// 日详情视图（24小时时间轴）
  Widget _buildDayDetailView(DateTime date) {
    final dateKey = CalendarUtils.formatDateKey(date);
    
    final dayCheckIns = checkIns.where((c) => CalendarUtils.formatDateKey(c.date) == dateKey).toList();
    final dayPomodoros = pomodoroRecords.where((p) => CalendarUtils.formatDateKey(p.startedAt) == dateKey).toList();
    final dayTodos = testTodos.where((t) => CalendarUtils.formatDateKey(t.startTime) == dateKey).toList();

    return Column(
      children: [
        _buildMiniWeekView(date),
        _buildDateHeader(date),
        if (dayCheckIns.isNotEmpty)
          _buildAllDayEventsSection(dayCheckIns),
        Expanded(
          child: _buildTimelineView(date, dayPomodoros, dayTodos),
        ),
      ],
    );
  }

  /// 迷你周视图
  Widget _buildMiniWeekView(DateTime selectedDate) {
    final weekStart = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final weekDates = List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekDates.map((date) {
          final isSelected = CalendarUtils.isSameDay(date, selectedDate);
          final isToday = CalendarUtils.isToday(date);
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onDateSelected(date),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    CalendarUtils.getWeekdayShort(date.weekday),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(color: Colors.red, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 日期标题
  Widget _buildDateHeader(DateTime date) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CalendarUtils.formatDateString(date),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            CalendarUtils.formatLunarDate(date),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 全天事件区域
  Widget _buildAllDayEventsSection(List<CheckIn> checkIns) {
    return Container(
      color: const Color(0xFFFFF4E6),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                '全天',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...checkIns.map((checkIn) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '📍 每日打卡',
                  style: TextStyle(fontSize: 14),
                ),
                if (checkIn.note != null && checkIn.note!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      checkIn.note!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// 24小时时间轴视图
  Widget _buildTimelineView(DateTime date, List<PomodoroRecord> pomodoros, List<TodoTestData> todos) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 24,
      itemBuilder: (context, hour) {
        final hourPomodoros = pomodoros.where((p) => p.startedAt.hour == hour).toList();
        final hourTodos = todos.where((t) => t.startTime.hour == hour).toList();
        return _buildTimelineHour(hour, hourPomodoros, hourTodos);
      },
    );
  }

  /// 构建时间轴的每个小时
  Widget _buildTimelineHour(int hour, List<PomodoroRecord> pomodoros, List<TodoTestData> todos) {
    final hasEvents = pomodoros.isNotEmpty || todos.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Container(
            width: 1,
            height: hasEvents ? null : 40,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: hasEvents
                ? Column(
                    children: [
                      ...pomodoros.map((p) => _buildPomodoroEventCard(p)),
                      ...todos.map((t) => _buildTodoEventCard(t)),
                    ],
                  )
                : Container(height: 40),
          ),
        ],
      ),
    );
  }

  /// 番茄钟事件卡片
  Widget _buildPomodoroEventCard(PomodoroRecord pomodoro) {
    String icon = '🍅';
    if (pomodoro.durationMinutes >= 90) {
      icon = '🔥';
    } else if (pomodoro.durationMinutes >= 60) {
      icon = '⚡';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pomodoro.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.pomodoro.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '专注工作',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pomodoro,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${CalendarUtils.formatTime(pomodoro.startedAt)} - ${CalendarUtils.formatTime(pomodoro.startedAt.add(Duration(minutes: pomodoro.durationMinutes)))}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '${pomodoro.durationMinutes}分钟',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (pomodoro.completed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '已完成',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 待办事项事件卡片
  Widget _buildTodoEventCard(TodoTestData todo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Text('✅', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${CalendarUtils.formatTime(todo.startTime)} - ${CalendarUtils.formatTime(todo.startTime.add(Duration(minutes: todo.durationMinutes)))}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '${todo.durationMinutes}分钟',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: todo.completed ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              todo.completed ? '已完成' : '待完成',
              style: TextStyle(
                fontSize: 11,
                color: todo.completed ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

