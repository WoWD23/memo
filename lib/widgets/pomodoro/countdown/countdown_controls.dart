import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../view_models/pomodoro/pomodoro_view_model.dart';

/// 倒计时控制按钮组件
class CountdownControls extends StatelessWidget {
  final PomodoroViewModel viewModel;

  const CountdownControls({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 暂停/继续按钮
            if (viewModel.state == PomodoroState.running ||
                viewModel.state == PomodoroState.paused)
              IconButton(
                onPressed: viewModel.togglePause,
                iconSize: 32,
                icon: Icon(
                  viewModel.state == PomodoroState.running
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(width: 24),
            // 跳过按钮
            if (viewModel.state == PomodoroState.running ||
                viewModel.state == PomodoroState.paused)
              IconButton(
                onPressed: () => _showSkipDialog(context),
                iconSize: 32,
                icon: const Icon(
                  Icons.skip_next,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(width: 24),
            // 重置按钮
            if (viewModel.state == PomodoroState.running ||
                viewModel.state == PomodoroState.paused)
              IconButton(
                onPressed: () => _showResetDialog(context),
                iconSize: 32,
                icon: const Icon(
                  Icons.stop_circle_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        );
      },
    );
  }

  /// 显示跳过确认对话框
  void _showSkipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('跳过'),
        content: const Text('确定要跳过当前倒计时吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              viewModel.skip();
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示重置确认对话框
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置'),
        content: const Text('确定要重置倒计时吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              viewModel.reset();
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

