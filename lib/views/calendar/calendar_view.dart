import 'package:flutter/material.dart';
import '../../repositories/check_in_repository.dart';
import '../../repositories/pomodoro_repository.dart';
import '../../models/check_in.dart';
import '../../models/pomodoro_record.dart';
import '../../core/theme/app_colors.dart';

/// 日历视图
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final CheckInRepository _checkInRepository = CheckInRepository();
  final PomodoroRepository _pomodoroRepository = PomodoroRepository();

  DateTime _selectedMonth = DateTime.now();
  List<CheckIn> _checkIns = [];
  Map<String, int> _pomodoroCountByDate = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

      // 加载打卡记录（添加超时）
      _checkIns = await _checkInRepository
          .getByDateRange(startOfMonth, endOfMonth)
          .timeout(const Duration(seconds: 5));

      // 加载番茄钟记录并统计每天的数量（添加超时）
      final pomodoroRecords = await _pomodoroRepository
          .getByDateRange(startOfMonth, endOfMonth)
          .timeout(const Duration(seconds: 5));
      
      _pomodoroCountByDate = {};
      for (var record in pomodoroRecords) {
        if (record.completed && record.mode == 'work') {
          final dateKey = _formatDateKey(record.startedAt);
          _pomodoroCountByDate[dateKey] = (_pomodoroCountByDate[dateKey] ?? 0) + 1;
        }
      }
    } catch (e) {
      // 加载失败时，使用空数据
      debugPrint('Failed to load calendar data: $e');
      _checkIns = [];
      _pomodoroCountByDate = {};
      
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载数据失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // 月份选择器
            _buildMonthSelector(),
            
            // 星期标题
            _buildWeekdayHeader(),
            
            // 日历网格
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCalendarGrid(),
            ),
            
            // 图例
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  /// 月份选择器
  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
              _loadData();
            },
          ),
          Text(
            '${_selectedMonth.year}年${_selectedMonth.month}月',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
              });
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  /// 星期标题
  Widget _buildWeekdayHeader() {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 14,
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

  /// 日历网格
  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday; // 1=Monday, 7=Sunday

    // 计算需要多少周
    final totalDays = daysInMonth + weekdayOfFirstDay - 1;
    final weeks = (totalDays / 7).ceil();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: weeks * 7,
      itemBuilder: (context, index) {
        final dayNumber = index - weekdayOfFirstDay + 2;
        
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
        final dateKey = _formatDateKey(date);
        final hasCheckIn = _checkIns.any((c) => _formatDateKey(c.date) == dateKey);
        final pomodoroCount = _pomodoroCountByDate[dateKey] ?? 0;
        final isToday = _isToday(date);

        return _buildDayCell(
          day: dayNumber,
          isToday: isToday,
          hasCheckIn: hasCheckIn,
          pomodoroCount: pomodoroCount,
          date: date,
        );
      },
    );
  }

  /// 日期单元格
  Widget _buildDayCell({
    required int day,
    required bool isToday,
    required bool hasCheckIn,
    required int pomodoroCount,
    required DateTime date,
  }) {
    return GestureDetector(
      onTap: () => _showDayDetail(date, hasCheckIn, pomodoroCount),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? AppColors.primary : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasCheckIn)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: const BoxDecoration(
                      color: AppColors.checkIn,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (pomodoroCount > 0)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: const BoxDecoration(
                      color: AppColors.pomodoro,
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

  /// 图例
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            color: AppColors.checkIn,
            label: '已打卡',
          ),
          const SizedBox(width: 24),
          _buildLegendItem(
            color: AppColors.pomodoro,
            label: '番茄钟',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 显示日期详情
  void _showDayDetail(DateTime date, bool hasCheckIn, int pomodoroCount) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDateString(date),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              icon: Icons.check_circle,
              label: '打卡状态',
              value: hasCheckIn ? '已打卡' : '未打卡',
              color: hasCheckIn ? AppColors.checkIn : Colors.grey,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.timer,
              label: '番茄钟',
              value: '$pomodoroCount 个',
              color: pomodoroCount > 0 ? AppColors.pomodoro : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 格式化日期为key（YYYY-MM-DD）
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化日期字符串
  String _formatDateString(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}年${date.month}月${date.day}日 $weekday';
  }

  /// 判断是否为今天
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

