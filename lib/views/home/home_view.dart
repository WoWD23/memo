import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/check_in/check_in_view_model.dart';
import '../../view_models/pomodoro/pomodoro_view_model.dart';
import '../../repositories/pomodoro_repository.dart';
import '../../core/theme/app_colors.dart';

/// 首页视图
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late CheckInViewModel _checkInViewModel;
  final PomodoroRepository _pomodoroRepository = PomodoroRepository();
  
  int _todayPomodoroCount = 0;
  int _todayFocusMinutes = 0;

  @override
  void initState() {
    super.initState();
    _checkInViewModel = CheckInViewModel();
    _loadData();
  }

  Future<void> _loadData() async {
    await _checkInViewModel.initialize();
    _todayPomodoroCount = await _pomodoroRepository.getTodayCompletedCount();
    _todayFocusMinutes = await _pomodoroRepository.getTodayFocusMinutes();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _checkInViewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 问候语
                    _buildGreeting(),
                    const SizedBox(height: 24),

                    // 今日概览卡片
                    _buildTodayOverview(),
                    const SizedBox(height: 16),

                    // 打卡状态卡片
                    _buildCheckInCard(),
                    const SizedBox(height: 16),

                    // 番茄钟统计卡片
                    _buildPomodoroCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 问候语
  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;
    
    if (hour < 12) {
      greeting = '早上好';
      icon = Icons.wb_sunny;
    } else if (hour < 18) {
      greeting = '下午好';
      icon = Icons.wb_sunny_outlined;
    } else {
      greeting = '晚上好';
      icon = Icons.nights_stay;
    }

    return Row(
      children: [
        Icon(icon, size: 32, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 今日概览
  Widget _buildTodayOverview() {
    return Consumer<CheckInViewModel>(
      builder: (context, checkInVM, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '今日概览',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOverviewItem(
                    icon: Icons.check_circle,
                    label: '打卡',
                    value: checkInVM.hasCheckedInToday ? '已完成' : '未完成',
                    completed: checkInVM.hasCheckedInToday,
                  ),
                  _buildOverviewItem(
                    icon: Icons.local_fire_department,
                    label: '连续',
                    value: '${checkInVM.streakDays}天',
                    completed: true,
                  ),
                  _buildOverviewItem(
                    icon: Icons.timer,
                    label: '番茄钟',
                    value: '$_todayPomodoroCount个',
                    completed: _todayPomodoroCount > 0,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String label,
    required String value,
    required bool completed,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 打卡状态卡片
  Widget _buildCheckInCard() {
    return Consumer<CheckInViewModel>(
      builder: (context, viewModel, child) {
        final hasCheckedIn = viewModel.hasCheckedInToday;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasCheckedIn
                      ? AppColors.checkIn.withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasCheckedIn ? Icons.check_circle : Icons.check_circle_outline,
                  size: 32,
                  color: hasCheckedIn ? AppColors.checkIn : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasCheckedIn ? '今日已打卡' : '今日未打卡',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasCheckedIn
                          ? '已连续打卡 ${viewModel.streakDays} 天，继续保持！'
                          : '点击前往打卡页面完成今日打卡',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 番茄钟统计卡片
  Widget _buildPomodoroCard() {
    return Consumer<PomodoroViewModel>(
      builder: (context, pomodoroVM, child) {
        final isRunning = pomodoroVM.state == PomodoroState.running;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.pomodoro.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.timer,
                      size: 28,
                      color: AppColors.pomodoro,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      '番茄钟',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isRunning)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pomodoro.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.pomodoro,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '进行中',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.pomodoro,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPomodoroStat(
                      label: '今日完成',
                      value: '$_todayPomodoroCount',
                      unit: '个',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: _buildPomodoroStat(
                      label: '专注时长',
                      value: '$_todayFocusMinutes',
                      unit: '分钟',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPomodoroStat({
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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
}

