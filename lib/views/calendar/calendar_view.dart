import 'package:flutter/material.dart';
import '../../repositories/check_in_repository.dart';
import '../../repositories/pomodoro_repository.dart';
import '../../models/check_in.dart';
import '../../models/pomodoro_record.dart';
import '../../core/theme/app_colors.dart';
import 'calendar_types.dart';
import 'calendar_compact_view.dart';
import 'calendar_stacked_view.dart';
import 'calendar_placeholder_view.dart';

/// 日历视图
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final CheckInRepository _checkInRepository = CheckInRepository();
  final PomodoroRepository _pomodoroRepository = PomodoroRepository();

  // 视图模式
  CalendarViewMode _viewMode = CalendarViewMode.compact;
  CalendarViewMode _previousViewMode = CalendarViewMode.compact; // 记录之前的视图模式
  CalendarDisplayState _displayState = CalendarDisplayState.collapsed;
  
  // 数据
  final DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1); // 固定为当前月，用于ListView生成
  DateTime _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1); // 用于顶部显示的月份（根据滚动位置动态更新）
  DateTime? _selectedDate;
  List<CheckIn> _checkIns = [];
  List<PomodoroRecord> _pomodoroRecords = [];
  Map<String, int> _pomodoroCountByDate = {};
  Map<String, int> _todoCountByDate = {};
  List<TodoTestData> _testTodos = [];
  bool _isLoading = false;

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToCurrentMonth = false;
  
  // 开发模式：显示测试数据
  bool _showTestData = true;

  @override
  void initState() {
    super.initState();
    // 添加滚动监听器，根据滚动位置更新显示的年份
    _scrollController.addListener(_onScroll);
    if (_showTestData) {
      _loadTestData();
    } else {
      _loadData();
    }
  }
  
  /// 滚动监听器：根据滚动位置更新当前显示的月份（仅更新顶部年份显示）
  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_displayState == CalendarDisplayState.expanded) return; // 展开详情时不更新
    
    final offset = _scrollController.offset;
    
    // 根据视图模式使用不同的月份高度
    final monthHeight = _viewMode == CalendarViewMode.stacked ? 460.0 : 400.0;
    
    // 计算当前滚动到第几个月（索引0-24，其中12是当前月）
    // 使用 floor 而不是 round，避免过于敏感
    final currentIndex = (offset / monthHeight + 0.3).floor(); // 加0.3确保滚动超过30%才切换
    
    // 根据索引计算月份
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final newMonth = DateTime(currentMonth.year, currentMonth.month + currentIndex - 12, 1);
    
    // 只更新 _displayedMonth 用于顶部显示，不影响 ListView 的内容
    if (newMonth.year != _displayedMonth.year || newMonth.month != _displayedMonth.month) {
      setState(() {
        _displayedMonth = newMonth;
      });
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasScrolledToCurrentMonth && _displayState == CalendarDisplayState.collapsed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentMonth();
      });
    }
  }
  
  /// 滚动到当前月份
  void _scrollToCurrentMonth({bool force = false}) {
    if (!mounted) return;
    if (!force && _hasScrolledToCurrentMonth) return;
    debugPrint('📍 滚动到当前月份: $_selectedMonth, 视图模式: $_viewMode, 强制: $force');
    _scrollToMonth(_selectedMonth);
    if (!force) _hasScrolledToCurrentMonth = true;
  }
  
  /// 滚动到指定月份
  void _scrollToMonth(DateTime targetMonth) {
    if (!mounted || !_scrollController.hasClients) return;
    
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final monthDiff = (targetMonth.year - currentMonth.year) * 12 + 
                     (targetMonth.month - currentMonth.month);
    
    final targetIndex = 12 + monthDiff;
    
    if (targetIndex < 0 || targetIndex > 24) return;
    
    // 叠放视图和紧凑视图使用不同的月份高度估算
    // 注意：叠放视图的图例在 ListView 外部，不影响滚动计算
    double estimatedMonthHeight;
    if (_viewMode == CalendarViewMode.stacked) {
      // 叠放视图每个月：月份标题(60) + 星期标题(28) + 日期网格(约350-380) ≈ 460px
      estimatedMonthHeight = 460.0;
    } else {
      // 紧凑视图
      estimatedMonthHeight = 400.0;
    }
    
    final targetOffset = targetIndex * estimatedMonthHeight;
    
    debugPrint('📏 目标月份: $targetMonth, 索引: $targetIndex, 视图: $_viewMode, 估计高度: $estimatedMonthHeight, 目标偏移: $targetOffset');
    
    try {
      if (_scrollController.position.hasContentDimensions) {
        final clampedOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
        debugPrint('🔄 实际滚动偏移: $clampedOffset (最大: ${_scrollController.position.maxScrollExtent})');
        _scrollController.jumpTo(clampedOffset);
      } else {
        _scrollController.jumpTo(targetOffset);
      }
    } catch (e) {
      debugPrint('Failed to scroll to month: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载数据
  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final startDate = DateTime(_selectedMonth.year, _selectedMonth.month - 12, 1);
      final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 13, 0);

      final checkIns = await _checkInRepository
          .getByDateRange(startDate, endDate)
          .timeout(const Duration(seconds: 5));

      final pomodoroRecords = await _pomodoroRepository
          .getByDateRange(startDate, endDate)
          .timeout(const Duration(seconds: 5));
      
      final pomodoroCountByDate = <String, int>{};
      for (var record in pomodoroRecords) {
        if (record.completed && record.mode == 'work') {
          final dateKey = CalendarUtils.formatDateKey(record.startedAt);
          pomodoroCountByDate[dateKey] = (pomodoroCountByDate[dateKey] ?? 0) + 1;
        }
      }
      
      if (mounted) {
        setState(() {
          _checkIns = checkIns;
          _pomodoroRecords = pomodoroRecords;
          _pomodoroCountByDate = pomodoroCountByDate;
        });
      }
    } catch (e) {
      debugPrint('Failed to load calendar data: $e');
      
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

  /// 加载测试数据
  void _loadTestData() {
    final now = DateTime.now();
    final testCheckIns = <CheckIn>[];
    final testPomodoros = <PomodoroRecord>[];
    final testTodos = <TodoTestData>[];
    
    final todoTemplates = [
      ('健身', 60, 7),
      ('会议', 90, 10),
      ('学习', 120, 14),
      ('购物', 30, 16),
      ('阅读', 45, 20),
    ];
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = CalendarUtils.formatDateKey(date);
      
      if (i % 3 != 0) {
        testCheckIns.add(CheckIn(
          date: date,
          createdAt: date,
          note: i % 5 == 0 ? '测试打卡备注' : null,
        ));
      }
      
      if (i % 5 != 0) {
        final pomodoroCount = (i % 3) + 1;
        for (int j = 0; j < pomodoroCount; j++) {
          final hour = 9 + j * 3;
          final startTime = DateTime(date.year, date.month, date.day, hour, 0);
          
          testPomodoros.add(PomodoroRecord(
            startedAt: startTime,
            durationMinutes: j == 0 ? 25 : (j == 1 ? 60 : 90),
            mode: 'work',
            completed: true,
          ));
        }
      }
      
      if (i % 2 == 0) {
        final todoNum = (i % 2) + 1;
        for (int j = 0; j < todoNum; j++) {
          final template = todoTemplates[(i + j) % todoTemplates.length];
          final startTime = DateTime(date.year, date.month, date.day, template.$3, 0);
          
          testTodos.add(TodoTestData(
            title: template.$1,
            startTime: startTime,
            durationMinutes: template.$2,
            completed: i > 0,
          ));
        }
        _todoCountByDate[dateKey] = todoNum;
      }
    }
    
    for (int i = 1; i <= 10; i++) {
      final date = now.add(Duration(days: i));
      final dateKey = CalendarUtils.formatDateKey(date);
      
      if (i % 2 == 0) {
        testCheckIns.add(CheckIn(
          date: date,
          createdAt: now,
          note: '未来计划',
        ));
      }
      
      if (i % 3 != 0) {
        final todoNum = (i % 2) + 1;
        for (int j = 0; j < todoNum; j++) {
          final template = todoTemplates[(i + j) % todoTemplates.length];
          final startTime = DateTime(date.year, date.month, date.day, template.$3, 0);
          
          testTodos.add(TodoTestData(
            title: template.$1,
            startTime: startTime,
            durationMinutes: template.$2,
            completed: false,
          ));
        }
        _todoCountByDate[dateKey] = todoNum;
      }
    }
    
    setState(() {
      _checkIns = [..._checkIns, ...testCheckIns];
      _pomodoroRecords = [..._pomodoroRecords, ...testPomodoros];
      _testTodos = testTodos;
      
      _pomodoroCountByDate = {};
      for (var record in _pomodoroRecords) {
        if (record.completed && record.mode == 'work') {
          final dateKey = CalendarUtils.formatDateKey(record.startedAt);
          _pomodoroCountByDate[dateKey] = (_pomodoroCountByDate[dateKey] ?? 0) + 1;
        }
      }
    });
    
    debugPrint('📅 已加载测试数据: ${testCheckIns.length} 个打卡, ${testPomodoros.length} 个番茄钟, ${testTodos.length} 个待办');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部导航栏
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          if (_displayState == CalendarDisplayState.expanded)
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final scrollToMonth = _selectedDate != null 
                    ? DateTime(_selectedDate!.year, _selectedDate!.month, 1)
                    : _displayedMonth;
                    
                setState(() {
                  _displayState = CalendarDisplayState.collapsed;
                  // 恢复之前的视图模式
                  _viewMode = _previousViewMode;
                  _displayedMonth = scrollToMonth;
                  _selectedDate = null;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToMonth(scrollToMonth);
                });
              },
            )
          else
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  const Icon(Icons.chevron_left, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${_displayedMonth.year}年',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          
          const Spacer(),
          
          PopupMenuButton<CalendarViewMode>(
            icon: const Icon(Icons.view_headline),
            offset: const Offset(0, 40),
            itemBuilder: (context) => [
              _buildViewModeMenuItem(CalendarViewMode.compact, '紧凑', Icons.view_compact),
              _buildViewModeMenuItem(CalendarViewMode.stacked, '叠放', Icons.view_agenda),
              _buildViewModeMenuItem(CalendarViewMode.detailed, '详细信息', Icons.view_module, enabled: false),
              _buildViewModeMenuItem(CalendarViewMode.list, '列表', Icons.view_list, enabled: false),
            ],
            onSelected: (mode) {
              setState(() {
                _viewMode = mode;
                _displayState = CalendarDisplayState.collapsed;
                _selectedDate = null;
                // 切换视图后，重置滚动标记，以便重新定位到当前月份
                _hasScrolledToCurrentMonth = false;
                // 重置显示月份为当前月
                _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
              });
              
              // 切换视图后滚动到当前月份
              // 使用 force: true 强制滚动，因为不同视图的月份高度不同
              // 使用多个延迟来确保视图完全渲染
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // 第一帧后等待布局完成
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _scrollToCurrentMonth(force: true);
                  }
                });
              });
            },
          ),
          
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
          
          if (_showTestData)
            Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: const Text(
                '测试',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  PopupMenuItem<CalendarViewMode> _buildViewModeMenuItem(
    CalendarViewMode mode,
    String label,
    IconData icon, {
    bool enabled = true,
  }) {
    final isSelected = _viewMode == mode;
    return PopupMenuItem<CalendarViewMode>(
      value: mode,
      enabled: enabled,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check : icon,
            size: 20,
            color: isSelected
                ? AppColors.primary
                : enabled
                    ? Colors.black87
                    : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.black87 : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// 根据视图模式构建内容
  Widget _buildContent() {
    switch (_viewMode) {
      case CalendarViewMode.compact:
        return CalendarCompactView(
          selectedMonth: _selectedMonth,
          selectedDate: _selectedDate,
          displayState: _displayState,
          checkIns: _checkIns,
          pomodoroRecords: _pomodoroRecords,
          pomodoroCountByDate: _pomodoroCountByDate,
          todoCountByDate: _todoCountByDate,
          testTodos: _testTodos,
          scrollController: _scrollController,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
              _displayState = CalendarDisplayState.expanded;
              _displayedMonth = DateTime(date.year, date.month, 1);
            });
          },
          onBack: () {
            setState(() {
              _displayState = CalendarDisplayState.collapsed;
              _selectedDate = null;
              // 返回时根据当前滚动位置更新显示月份
              if (_scrollController.hasClients) {
                final offset = _scrollController.offset;
                final monthHeight = _viewMode == CalendarViewMode.stacked ? 460.0 : 400.0;
                final currentIndex = (offset / monthHeight + 0.3).floor();
                final currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
                _displayedMonth = DateTime(currentMonth.year, currentMonth.month + currentIndex - 12, 1);
              }
            });
          },
        );
      
      case CalendarViewMode.stacked:
        return CalendarStackedView(
          selectedMonth: _selectedMonth,
          checkIns: _checkIns,
          pomodoroCountByDate: _pomodoroCountByDate,
          todoCountByDate: _todoCountByDate,
          scrollController: _scrollController,
          onDateSelected: (date) {
            setState(() {
              _previousViewMode = _viewMode; // 保存当前视图模式
              _selectedDate = date;
              _displayState = CalendarDisplayState.expanded;
              _viewMode = CalendarViewMode.compact; // 切换到紧凑视图查看详情
              _displayedMonth = DateTime(date.year, date.month, 1);
            });
          },
          onViewModeChange: () {
            setState(() {
              _previousViewMode = _viewMode;
              _viewMode = CalendarViewMode.compact;
            });
          },
        );
      
      case CalendarViewMode.detailed:
        return const CalendarPlaceholderView(title: '详细信息视图');
      
      case CalendarViewMode.list:
        return const CalendarPlaceholderView(title: '列表视图');
    }
  }
}
