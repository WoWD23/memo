import 'package:flutter/material.dart';
import '../../../view_models/pomodoro/pomodoro_view_model.dart';

/// 番茄钟倒计时显示组件
class PomodoroCountdown extends StatelessWidget {
  final PomodoroViewModel viewModel;

  const PomodoroCountdown({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 倒计时数字显示
            Text(
              viewModel.formattedTime,
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Color(viewModel.modeColor),
              ),
            ),
            const SizedBox(height: 16),
            // 模式指示器
            Text(
              viewModel.modeText,
              style: TextStyle(
                fontSize: 18,
                color: Color(viewModel.modeColor),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}

