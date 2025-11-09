import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../view_models/pomodoro/pomodoro_view_model.dart';
import '../countdown/countdown_controls.dart';
import 'clock_face.dart';

/// 时钟时间选择器主组件
class ClockTimePicker extends StatefulWidget {
  final Function(Duration) onTimeSelected;
  final VoidCallback? onCancel;
  final VoidCallback? onCalendarTap; // 点击日历按钮回调
  final Duration? remainingTime; // 倒计时剩余时间
  final Duration? totalTime; // 总时间

  const ClockTimePicker({
    super.key,
    required this.onTimeSelected,
    this.onCancel,
    this.onCalendarTap,
    this.remainingTime,
    this.totalTime,
  });

  @override
  State<ClockTimePicker> createState() => _ClockTimePickerState();
}

class _ClockTimePickerState extends State<ClockTimePicker> {
  int _hour = 0;
  int _minute = 25; // 默认25分钟
  int _selectedMinutes = 25; // 选择的分钟数（0-120）

  @override
  void initState() {
    super.initState();
    _selectedMinutes = _hour * 60 + _minute;
    // 限制在0-120分钟之间
    if (_selectedMinutes > 120) {
      _selectedMinutes = 120;
      _hour = 2;
      _minute = 0;
    }
  }

  @override
  void didUpdateWidget(ClockTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当从倒计时模式返回到选择模式时，更新选择的时间
    if (oldWidget.remainingTime != null && widget.remainingTime == null) {
      // 倒计时结束或取消，保持当前选择不变
      // 不需要更新状态
    } else if (oldWidget.remainingTime == null && widget.remainingTime != null) {
      // 开始倒计时，根据总时间更新显示
      if (widget.totalTime != null) {
        final totalMinutes = widget.totalTime!.inMinutes;
        setState(() {
          _selectedMinutes = totalMinutes;
          _hour = totalMinutes ~/ 60;
          _minute = totalMinutes % 60;
        });
      }
    }
  }

  void _handleTimeChanged(int hour, int minute) {
    final newMinutes = hour * 60 + minute;
    // 限制在0-120分钟之间
    if (newMinutes > 120) return; // 超过120分钟，不更新
    
    setState(() {
      _hour = hour;
      _minute = minute;
      _selectedMinutes = newMinutes;
    });
  }

  void _handleOK() {
    // 直接使用选择的分钟数（0-120分钟），限制最大120分钟
    final minutes = _selectedMinutes > 120 ? 120 : _selectedMinutes;
    if (minutes <= 0) return; // 至少1分钟
    widget.onTimeSelected(Duration(minutes: minutes));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final clockSize = screenWidth * 0.7;
    final isCountdownMode = widget.remainingTime != null && widget.totalTime != null;
    
    // 调试：打印当前状态
    debugPrint('ClockTimePicker build: isCountdownMode=$isCountdownMode, remainingTime=${widget.remainingTime}, totalTime=${widget.totalTime}');

    return Container(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 计算可用高度
          final availableHeight = constraints.maxHeight;
          final titleHeight = 16.0 + 24.0; // "Select time" 标题高度 + 间距
          final timeDisplayHeight = 60.0 + 32.0; // 时间显示高度 + 间距
          // 底部按钮区域高度：模式文字(18) + 间距(16) + 控制按钮(48) + 间距(8) + Cancel按钮(36) + 底部间距(16) = 142
          final buttonsHeight = isCountdownMode ? 142.0 : 60.0; // 倒计时模式需要更多空间
          final spacing = 16.0; // 底部间距
          final clockAvailableHeight = availableHeight - titleHeight - timeDisplayHeight - buttonsHeight - spacing;
          
          // 确保时钟盘大小不超过可用空间，但至少保持一定大小
          final actualClockSize = math.min(clockSize, math.max(clockAvailableHeight * 0.85, 200.0));
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部显示：选择时间标题（始终显示）
              const Text(
                'Select time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // 时间显示区域（选择模式显示选择的分钟数，倒计时模式显示剩余分钟数）
              // 使用固定高度的容器，避免布局跳动
              SizedBox(
                height: 60, // 固定高度，与时间显示框的高度一致
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: !isCountdownMode
                        ? _buildMinutesDisplay()
                        : _buildCountdownMinutesDisplay(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // 时钟盘（选择模式和倒计时模式共用，倒计时时在时钟中心显示倒计时）
              // 使用Expanded让时钟盘占据剩余空间
              Expanded(
                child: IgnorePointer(
                  // 倒计时模式下锁定交互
                  ignoring: isCountdownMode,
                  child: Center(
                    child: ClockFace(
                      size: actualClockSize,
                      selectedHour: _hour,
                      selectedMinute: _minute,
                      onTimeChanged: (hour, minute) {
                        final newMinutes = hour * 60 + minute;
                        // 限制在0-120分钟之间
                        if (newMinutes <= 120) {
                          _handleTimeChanged(hour, minute);
                        }
                      },
                      remainingTime: widget.remainingTime,
                      totalTime: widget.totalTime,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 底部按钮区域（根据模式使用不同高度）
              SizedBox(
                height: isCountdownMode ? 142.0 : 60.0, // 倒计时模式需要更多高度
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: !isCountdownMode
                      ? _buildSelectModeButtons()
                      : _buildCountdownControls(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建分钟数显示
  Widget _buildMinutesDisplay() {
    final hours = _selectedMinutes ~/ 60;
    final minutes = _selectedMinutes % 60;
    
    return Row(
      key: const ValueKey('minutes_display'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 小时显示（如果大于0）
        if (hours > 0) ...[
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryVeryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              hours.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            ':',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
        ],
        // 分钟显示
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: hours > 0 ? AppColors.primaryVeryLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: hours > 0 ? null : Border.all(
              color: AppColors.divider,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            minutes.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: hours > 0 ? AppColors.primaryDark : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 单位显示
        Text(
          '分钟',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 构建选择模式按钮
  Widget _buildSelectModeButtons() {
    return Row(
      key: const ValueKey('select_mode_buttons'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 日历图标按钮（跳转到日历Tab）
        IconButton(
          onPressed: widget.onCalendarTap,
          icon: const Icon(
            Icons.calendar_today,
            color: AppColors.textSecondary,
          ),
        ),
        // Cancel 和 OK 按钮
        Row(
          children: [
            TextButton(
              onPressed: widget.onCancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: _selectedMinutes > 0 ? _handleOK : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  color: _selectedMinutes > 0
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建倒计时分钟数显示（与选择时间显示格式一致）
  Widget _buildCountdownMinutesDisplay() {
    // 使用 Consumer 来监听 ViewModel 的变化，确保倒计时实时更新
    return Consumer<PomodoroViewModel>(
      builder: (context, vm, child) {
        final remaining = vm.remainingTime;
        final totalMinutes = remaining.inMinutes;
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        
        // 显示格式与选择时间一致：如果大于1小时显示小时:分钟，否则只显示分钟
        return Row(
          key: const ValueKey('countdown_minutes_display'),
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 小时显示（如果大于0）
            if (hours > 0) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryVeryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  hours.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                ':',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            // 分钟显示
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: hours > 0 ? AppColors.primaryVeryLight : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: hours > 0 ? null : Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                minutes.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: hours > 0 ? AppColors.primaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 单位显示
            Text(
              '分钟',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建倒计时控制按钮（显示在时钟下方）
  Widget _buildCountdownControls(BuildContext context) {
    return Consumer<PomodoroViewModel>(
      builder: (context, vm, child) {
        if (vm.state != PomodoroState.running && vm.state != PomodoroState.paused) {
          return const SizedBox.shrink();
        }
        
        return Column(
          key: const ValueKey('countdown_controls'),
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 模式指示器（显示在控制按钮上方）
            Text(
              vm.modeText,
              style: TextStyle(
                fontSize: 18,
                color: Color(vm.modeColor),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // 控制按钮（暂停、跳过、重置）
            CountdownControls(viewModel: vm),
            const SizedBox(height: 8),
            // Cancel按钮
            TextButton(
              onPressed: widget.onCancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

