import 'package:flutter/foundation.dart';

/// 导航视图模型 - 管理全局导航状态
class NavigationViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  /// 切换到指定的 tab
  void switchToTab(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// 切换到日历 tab
  void switchToCalendar() {
    switchToTab(1); // 日历是第二个 tab (index = 1)
  }

  /// 切换到首页 tab
  void switchToHome() {
    switchToTab(2); // 首页是第三个 tab (index = 2)
  }

  /// 切换到待办 tab
  void switchToTodo() {
    switchToTab(3); // 待办是第四个 tab (index = 3)
  }

  /// 切换到设置 tab
  void switchToSettings() {
    switchToTab(4); // 设置是第五个 tab (index = 4)
  }

  /// 切换到番茄钟 tab
  void switchToPomodoro() {
    switchToTab(0); // 番茄钟是第一个 tab (index = 0)
  }
}

