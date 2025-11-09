import 'package:flutter/material.dart';
import '../../models/check_in.dart';
import 'calendar_types.dart';

/// 叠放视图组件
class CalendarStackedView extends StatelessWidget {
  final DateTime selectedMonth;
  final List<CheckIn> checkIns;
  final Map<String, int> pomodoroCountByDate;
  final Map<String, int> todoCountByDate;
  final ScrollController scrollController;
  final Function(DateTime date) onDateSelected;
  final VoidCallback onViewModeChange;

  const CalendarStackedView({
    super.key,
    required this.selectedMonth,
    required this.checkIns,
    required this.pomodoroCountByDate,
    required this.todoCountByDate,
    required this.scrollController,
    required this.onDateSelected,
    required this.onViewModeChange,
  });

  @override
  Widget build(BuildContext context) {
    // 生成前后各12个月的月份列表（与紧凑视图一致）
    final months = <DateTime>[];
    for (int i = -12; i <= 12; i++) {
      months.add(DateTime(selectedMonth.year, selectedMonth.month + i, 1));
    }

    return Column(
      children: [
        _buildStackedLegend(),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              return _buildStackedMonthSection(month);
            },
          ),
        ),
      ],
    );
  }

  /// 叠放视图图例
  Widget _buildStackedLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            '图例：',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          _buildStackedLegendItem(Colors.green, '打卡'),
          const SizedBox(width: 12),
          _buildStackedLegendItem(Colors.orange, '番茄钟'),
          const SizedBox(width: 12),
          _buildStackedLegendItem(Colors.blue, '待办'),
        ],
      ),
    );
  }

  Widget _buildStackedLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  /// 构建叠放模式的月份区域
  Widget _buildStackedMonthSection(DateTime month) {
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
        _buildStackedMonthGrid(month),
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

  /// 构建叠放模式的月份网格
  Widget _buildStackedMonthGrid(DateTime month) {
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
          return Column(
            children: [
              Row(
                children: List.generate(7, (dayIndex) {
                  final cellIndex = weekIndex * 7 + dayIndex;
                  final dayNumber = cellIndex - weekdayOfFirstDay + 2;
                  
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return Expanded(child: Container(height: 30));
                  }

                  final date = DateTime(month.year, month.month, dayNumber);
                  return Expanded(
                    child: _buildStackedDayHeader(date),
                  );
                }),
              ),
              _buildStackedWeekEvents(month, weekIndex, weekdayOfFirstDay, daysInMonth),
              const SizedBox(height: 8),
            ],
          );
        }),
      ),
    );
  }

  /// 构建叠放模式的日期头部
  Widget _buildStackedDayHeader(DateTime date) {
    final isToday = CalendarUtils.isToday(date);
    final isWeekend = date.weekday == 6 || date.weekday == 7;

    return Container(
      height: 30,
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          color: isToday
              ? Colors.red
              : isWeekend
                  ? Colors.grey[400]
                  : Colors.black87,
        ),
      ),
    );
  }

  /// 构建一周的事件横杠
  Widget _buildStackedWeekEvents(DateTime month, int weekIndex, int weekdayOfFirstDay, int daysInMonth) {
    final weekDates = <DateTime>[];
    
    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final cellIndex = weekIndex * 7 + dayIndex;
      final dayNumber = cellIndex - weekdayOfFirstDay + 2;
      
      if (dayNumber >= 1 && dayNumber <= daysInMonth) {
        weekDates.add(DateTime(month.year, month.month, dayNumber));
      } else {
        weekDates.add(DateTime(1900, 1, 1));
      }
    }

    return Column(
      children: [
        _buildEventBar(weekDates, EventType.checkIn),
        const SizedBox(height: 2),
        _buildEventBar(weekDates, EventType.pomodoro),
        const SizedBox(height: 2),
        _buildEventBar(weekDates, EventType.todo),
      ],
    );
  }

  /// 构建事件横杠
  Widget _buildEventBar(List<DateTime> weekDates, EventType eventType) {
    return SizedBox(
      height: 8,
      child: Row(
        children: weekDates.map((date) {
          if (date.year == 1900) {
            return Expanded(child: Container());
          }

          final dateKey = CalendarUtils.formatDateKey(date);
          bool hasEvent = false;

          switch (eventType) {
            case EventType.checkIn:
              hasEvent = checkIns.any((c) => CalendarUtils.formatDateKey(c.date) == dateKey);
              break;
            case EventType.pomodoro:
              hasEvent = (pomodoroCountByDate[dateKey] ?? 0) > 0;
              break;
            case EventType.todo:
              hasEvent = (todoCountByDate[dateKey] ?? 0) > 0;
              break;
          }

          return Expanded(
            child: GestureDetector(
              onTap: hasEvent ? () {
                onViewModeChange();
                onDateSelected(date);
              } : null,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: hasEvent ? _getEventColor(eventType) : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 获取事件颜色
  Color _getEventColor(EventType eventType) {
    switch (eventType) {
      case EventType.checkIn:
        return Colors.green;
      case EventType.pomodoro:
        return Colors.orange;
      case EventType.todo:
        return Colors.blue;
    }
  }
}

