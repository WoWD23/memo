import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/pomodoro/time_picker/clock_time_picker.dart';
import '../../view_models/pomodoro/pomodoro_view_model.dart';
import '../../view_models/navigation_view_model.dart';

/// 番茄钟视图
class PomodoroView extends StatefulWidget {
  const PomodoroView({super.key});

  @override
  State<PomodoroView> createState() => _PomodoroViewState();
}

class _PomodoroViewState extends State<PomodoroView> {
  @override
  Widget build(BuildContext context) {
    // 获取 NavigationViewModel 用于跳转到日历 tab
    final navigationViewModel = Provider.of<NavigationViewModel>(context, listen: false);
    
    return Consumer<PomodoroViewModel>(
      builder: (context, viewModel, child) {
        // 确保在同一个页面内，根据状态切换显示内容
        final isCountdownMode = viewModel.state != PomodoroState.idle;
        
        // 调试：打印当前状态
        debugPrint('PomodoroView build: state=${viewModel.state}, isCountdownMode=$isCountdownMode, remainingTime=${viewModel.remainingTime}, totalTime=${viewModel.totalDuration}');
        
        return PopScope(
          // 锁定返回按钮（倒计时期间）
          canPop: !viewModel.isLocked,
          onPopInvokedWithResult: (didPop, result) async {
            if (viewModel.isLocked && !didPop) {
              // 如果已锁定，显示取消确认对话框
              final shouldCancel = await _showCancelDialog(context, viewModel);
              if (shouldCancel == true) {
                viewModel.cancel();
                // 注意：这里不应该pop，因为我们在同一个页面
              }
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F5F5), // 浅灰色背景
            body: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                // 统一使用时钟选择器，根据状态显示不同内容
                // 关键：同一个Widget，只是根据状态改变显示内容
                // 移除key，让Flutter自动管理widget的更新
                child: ClockTimePicker(
                  onTimeSelected: (duration) {
                    debugPrint('onTimeSelected called with duration: $duration');
                    // 点击OK时，开始倒计时，不跳转页面
                    viewModel.startCountdown(duration);
                    debugPrint('startCountdown called, new state: ${viewModel.state}');
                  },
                  onCancel: () {
                    if (viewModel.isLocked) {
                      // 倒计时模式下显示取消确认对话框
                      _showCancelDialog(context, viewModel);
                    }
                  },
                  onCalendarTap: () {
                    // 点击日历按钮，跳转到日历 tab
                    navigationViewModel.switchToCalendar();
                  },
                  remainingTime: isCountdownMode ? viewModel.remainingTime : null,
                  totalTime: isCountdownMode ? viewModel.totalDuration : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  /// 显示取消确认对话框
  Future<bool?> _showCancelDialog(
    BuildContext context,
    PomodoroViewModel viewModel,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // 不允许点击外部关闭
      builder: (context) => AlertDialog(
        title: const Text('取消倒计时'),
        content: const Text('确定要取消当前倒计时吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // 否
            child: const Text('否'),
          ),
          TextButton(
            onPressed: () {
              viewModel.cancel();
              Navigator.of(context).pop(true); // 是
            },
            child: const Text('是'),
          ),
        ],
      ),
    );
  }
}

