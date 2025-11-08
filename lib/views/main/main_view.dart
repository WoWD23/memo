import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_view.dart';
import '../pomodoro/pomodoro_view.dart';
import '../calendar/calendar_view.dart';
import '../settings/settings_view.dart';
import '../todo/todo_view.dart';
import '../../widgets/navigation/custom_bottom_nav_bar.dart';
import '../../view_models/pomodoro/pomodoro_view_model.dart';

/// 主页面视图（包含底部导航栏）
class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;
  PomodoroViewModel? _pomodoroViewModel;

  final List<Widget> _pages = const [
    PomodoroView(), // focast - 番茄钟（第一个）
    CalendarView(), // calendar - 日历（第二个）
    HomeView(), // Home - 首页（第三个）
    TodoView(), // TODO - 待办（第四个）
    SettingsView(), // setting - 设置（第五个）
  ];

  void _onTabTapped(int index) {
    // 如果番茄钟正在运行且锁定，不允许切换Tab
    if (_pomodoroViewModel != null && _pomodoroViewModel!.isLocked) {
      return;
    }
    
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroViewModel>(
      builder: (context, pomodoroViewModel, child) {
        _pomodoroViewModel = pomodoroViewModel;
        
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: IgnorePointer(
            // 如果番茄钟锁定，禁用底部导航栏
            ignoring: pomodoroViewModel.isLocked,
            child: Opacity(
              opacity: pomodoroViewModel.isLocked ? 0.5 : 1.0,
              child: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
              ),
            ),
          ),
        );
      },
    );
  }
}

