import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 时钟盘绘制组件
class ClockFace extends StatefulWidget {
  final double size;
  final int selectedHour;
  final int selectedMinute;
  final Function(int, int) onTimeChanged;
  final Duration? remainingTime; // 倒计时剩余时间
  final Duration? totalTime; // 总时间（用于计算进度）

  const ClockFace({
    super.key,
    required this.size,
    required this.selectedHour,
    required this.selectedMinute,
    required this.onTimeChanged,
    this.remainingTime,
    this.totalTime,
  });

  @override
  State<ClockFace> createState() => _ClockFaceState();
}

class _ClockFaceState extends State<ClockFace> {
  late int _hour;
  late int _minute;
  int _selectedMinutes = 0; // 选择的分钟数（0-120）

  @override
  void initState() {
    super.initState();
    _hour = widget.selectedHour;
    _minute = widget.selectedMinute;
    _selectedMinutes = _hour * 60 + _minute;
    // 限制在0-120分钟之间
    if (_selectedMinutes > 120) _selectedMinutes = 120;
  }

  @override
  void didUpdateWidget(ClockFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedHour != oldWidget.selectedHour ||
        widget.selectedMinute != oldWidget.selectedMinute) {
      _hour = widget.selectedHour;
      _minute = widget.selectedMinute;
      _selectedMinutes = _hour * 60 + _minute;
      // 限制在0-120分钟之间
      if (_selectedMinutes > 120) _selectedMinutes = 120;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final center = Offset(widget.size / 2, widget.size / 2);
    final offset = localPosition - center;
    
    // 计算角度（从12点开始，顺时针）
    double angle = math.atan2(offset.dy, offset.dx);
    angle = angle + math.pi / 2; // 调整到12点开始
    if (angle < 0) angle += 2 * math.pi;
    
    // 计算距离中心的距离
    final distance = math.sqrt(offset.dx * offset.dx + offset.dy * offset.dy);
    final radius = widget.size / 2;
    
    // 只在时钟盘边缘区域响应（避免中心区域误触）
    if (distance > radius * 0.3 && distance < radius * 0.9) {
      // 将角度转换为分钟数（0-120分钟，一圈对应120分钟）
      // angle的范围：0到2π
      // 0分钟在12点（angle = -π/2，归一化后 = 3π/2）
      // 需要将角度归一化到0-2π范围
      double normalizedAngle = angle;
      if (normalizedAngle < 0) normalizedAngle += 2 * math.pi;
      
      // 将角度转换为分钟数
      // 12点位置（3π/2）对应0分钟
      // 需要调整：从12点开始顺时针
      double minutesFromAngle = (normalizedAngle / (2 * math.pi)) * 120;
      
      // 处理12点位置的特殊情况（0分钟和120分钟在同一个位置）
      // 如果角度接近12点（3π/2），需要判断是0分钟还是120分钟
      // 根据当前位置判断：如果当前选择接近120，则设为120；否则设为0
      if (minutesFromAngle > 118) {
        // 非常接近120分钟位置
        minutesFromAngle = 120;
      } else if (minutesFromAngle < 2) {
        // 非常接近0分钟位置
        minutesFromAngle = 0;
      }
      
      // 四舍五入到最接近的分钟（支持每分钟精度）
      int newMinutes = minutesFromAngle.round();
      
      // 限制在0-120分钟之间
      if (newMinutes < 0) newMinutes = 0;
      if (newMinutes > 120) newMinutes = 120;
      
      if (newMinutes != _selectedMinutes) {
        setState(() {
          _selectedMinutes = newMinutes;
          // 转换为小时和分钟
          _hour = newMinutes ~/ 60;
          _minute = newMinutes % 60;
        });
        widget.onTimeChanged(_hour, _minute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCountdownMode = widget.remainingTime != null && widget.totalTime != null;
    
    return GestureDetector(
      onPanUpdate: isCountdownMode ? null : _handlePanUpdate, // 倒计时模式下禁用拖动
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _ClockFacePainter(
          selectedMinutes: _selectedMinutes,
          remainingTime: widget.remainingTime,
          totalTime: widget.totalTime,
          isCountdownMode: isCountdownMode,
        ),
      ),
    );
  }
}

class _ClockFacePainter extends CustomPainter {
  final int selectedMinutes; // 选择的分钟数（0-120）
  final Duration? remainingTime;
  final Duration? totalTime;
  final bool isCountdownMode;

  _ClockFacePainter({
    required this.selectedMinutes,
    this.remainingTime,
    this.totalTime,
    this.isCountdownMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 绘制时钟盘背景
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 绘制时钟盘边框
    final borderPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, borderPaint);

    if (isCountdownMode && remainingTime != null && totalTime != null) {
      // 倒计时模式：显示倒计时
      _paintCountdownMode(canvas, size, center, radius);
    } else {
      // 选择模式：显示时间选择器
      _paintSelectionMode(canvas, size, center, radius);
    }
  }

  /// 绘制选择模式（2小时一圈，120分钟）
  void _paintSelectionMode(Canvas canvas, Size size, Offset center, double radius) {
    // 绘制分钟刻度标记
    // 每20分钟一个大刻度（带数字）
    // 每5分钟一个中等刻度
    // 每分钟一个小刻度
    for (int minutes = 0; minutes < 120; minutes++) {
      // 计算角度（从12点开始，顺时针）
      // 0分钟在12点，120分钟转完一圈回到12点
      final angle = (minutes / 120.0 * 2 * math.pi) - (math.pi / 2);
      
      // 判断刻度类型
      final isMajorTick = minutes % 20 == 0; // 每20分钟一个主要刻度（带数字）
      final isMediumTick = minutes % 5 == 0 && !isMajorTick; // 每5分钟一个中等刻度
      final isMinorTick = !isMajorTick && !isMediumTick; // 其他为小刻度
      
      // 刻度位置（根据刻度类型调整长度）
      double tickStartRadius, tickEndRadius;
      if (isMajorTick) {
        tickStartRadius = radius * 0.75;
        tickEndRadius = radius * 0.92;
      } else if (isMediumTick) {
        tickStartRadius = radius * 0.8;
        tickEndRadius = radius * 0.9;
      } else {
        tickStartRadius = radius * 0.83;
        tickEndRadius = radius * 0.88;
      }
      
      final tickStart = Offset(
        center.dx + tickStartRadius * math.cos(angle),
        center.dy + tickStartRadius * math.sin(angle),
      );
      final tickEnd = Offset(
        center.dx + tickEndRadius * math.cos(angle),
        center.dy + tickEndRadius * math.sin(angle),
      );
      
      // 绘制刻度线
      final tickPaint = Paint()
        ..color = isMinorTick 
            ? AppColors.textSecondary.withValues(alpha: 0.4)
            : AppColors.textSecondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = isMajorTick ? 2.5 : (isMediumTick ? 1.5 : 1.0);
      canvas.drawLine(tickStart, tickEnd, tickPaint);
      
      // 绘制主要刻度数字
      if (isMajorTick && minutes > 0) {
        // 0分钟位置不显示数字（会在选中时显示）
        final numberRadius = radius * 0.65;
        final numberPosition = Offset(
          center.dx + numberRadius * math.cos(angle),
          center.dy + numberRadius * math.sin(angle),
        );
        
        // 显示分钟数
        final textPainter = TextPainter(
          text: TextSpan(
            text: minutes.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            numberPosition.dx - textPainter.width / 2,
            numberPosition.dy - textPainter.height / 2,
          ),
        );
      }
    }
    
    // 在12点位置显示"0"或"120"（根据选中位置）
    final zeroAngle = -math.pi / 2; // 12点位置
    if (selectedMinutes == 0 || selectedMinutes == 120) {
      // 如果选中0或120，不显示额外的数字
    } else {
      // 在12点位置显示"0"标记
      final zeroRadius = radius * 0.65;
      final zeroPosition = Offset(
        center.dx + zeroRadius * math.cos(zeroAngle),
        center.dy + zeroRadius * math.sin(zeroAngle),
      );
      final zeroTextPainter = TextPainter(
        text: const TextSpan(
          text: '0',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      zeroTextPainter.layout();
      zeroTextPainter.paint(
        canvas,
        Offset(
          zeroPosition.dx - zeroTextPainter.width / 2,
          zeroPosition.dy - zeroTextPainter.height / 2,
        ),
      );
    }
    
    // 绘制选中位置的指示器
    // 计算角度：0分钟和120分钟都在12点位置（-π/2）
    double selectedAngle;
    if (selectedMinutes == 120) {
      // 120分钟转完一圈，回到12点
      selectedAngle = -math.pi / 2;
    } else {
      // 0-119分钟，从12点开始顺时针
      selectedAngle = (selectedMinutes / 120.0 * 2 * math.pi) - (math.pi / 2);
    }
    
    final indicatorRadius = radius * 0.75;
    final indicatorPosition = Offset(
      center.dx + indicatorRadius * math.cos(selectedAngle),
      center.dy + indicatorRadius * math.sin(selectedAngle),
    );
    
    // 绘制选中指示器（圆形背景）
    final indicatorPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(indicatorPosition, 20, indicatorPaint);
    
    // 绘制选中的分钟数
    final displayText = selectedMinutes == 120 ? '120' : selectedMinutes.toString();
    final selectedTextPainter = TextPainter(
      text: TextSpan(
        text: displayText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    selectedTextPainter.layout();
    selectedTextPainter.paint(
      canvas,
      Offset(
        indicatorPosition.dx - selectedTextPainter.width / 2,
        indicatorPosition.dy - selectedTextPainter.height / 2,
      ),
    );

    // 绘制指针（从中心指向选中的位置）
    final pointerPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final pointerEnd = Offset(
      center.dx + (radius * 0.7) * math.cos(selectedAngle),
      center.dy + (radius * 0.7) * math.sin(selectedAngle),
    );
    canvas.drawLine(center, pointerEnd, pointerPaint);
    
    // 绘制指针末端圆点
    final pointerDotPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pointerEnd, 6, pointerDotPaint);
  }

  /// 绘制倒计时模式
  void _paintCountdownMode(Canvas canvas, Size size, Offset center, double radius) {
    if (remainingTime == null || totalTime == null) return;

    final totalMinutes = totalTime!.inMinutes.clamp(0, 120); // 限制最大120分钟
    final remainingMinutes = remainingTime!.inMinutes;
    final remainingSeconds = remainingTime!.inSeconds % 60;
    final progress = totalMinutes > 0 ? (remainingMinutes / totalMinutes).clamp(0.0, 1.0) : 0.0;

    // 计算剩余时间对应的角度（从选择的位置开始，倒转回12点）
    // 选择的时间位置：totalMinutes / 120 * 360度（从12点开始，顺时针）
    // 剩余时间比例：progress
    // 当前指针角度：从选择位置倒转回12点
    
    // 选择的位置角度（从12点开始，顺时针）
    // 0分钟在12点（-90度），120分钟转完一圈回到12点（-90度）
    double selectedAngle;
    if (totalMinutes == 120) {
      // 120分钟转完一圈，回到12点
      selectedAngle = -math.pi / 2;
    } else {
      // 0-119分钟，从12点开始顺时针
      selectedAngle = (totalMinutes / 120.0 * 2 * math.pi) - (math.pi / 2);
    }
    
    // 当前指针角度（从选择位置倒转回12点）
    // progress = 1.0 时，角度 = selectedAngle（选择的位置）
    // progress = 0.0 时，角度 = -90度（12点）
    final twelveOClockAngle = -math.pi / 2; // 12点位置
    final angleRange = selectedAngle - twelveOClockAngle;
    final currentAngle = twelveOClockAngle + angleRange * progress;

    // 绘制进度圆弧（已过时间，从选择位置到当前位置）
    final progressPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    
    // 绘制从当前指针位置到选择位置的圆弧（已过时间）
    final arcStartAngle = currentAngle;
    final sweepAngle = selectedAngle - currentAngle;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      arcStartAngle,
      sweepAngle,
      false,
      progressPaint,
    );
    
    // 绘制分钟刻度（倒计时模式下也显示，但更淡）
    for (int minutes = 0; minutes <= 120; minutes += 20) {
      final tickAngle = (minutes / 120.0 * 2 * math.pi) - (math.pi / 2);
      final tickStartRadius = radius * 0.85;
      final tickEndRadius = radius * 0.9;
      
      final tickStart = Offset(
        center.dx + tickStartRadius * math.cos(tickAngle),
        center.dy + tickStartRadius * math.sin(tickAngle),
      );
      final tickEnd = Offset(
        center.dx + tickEndRadius * math.cos(tickAngle),
        center.dy + tickEndRadius * math.sin(tickAngle),
      );
      
      final tickPaint = Paint()
        ..color = AppColors.textSecondary.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(tickStart, tickEnd, tickPaint);
    }

    // 在时钟中心显示倒计时数字（MM:SS格式，大字体）
    final totalMinutesDisplay = totalMinutes;
    final minutesDisplay = remainingMinutes;
    final secondsDisplay = remainingSeconds;
    
    // 显示格式：MM:SS（如果总时间小于1小时）或 HH:MM:SS（如果总时间大于1小时）
    final timeText = totalMinutesDisplay < 60
        ? '${minutesDisplay.toString().padLeft(2, '0')}:${secondsDisplay.toString().padLeft(2, '0')}'
        : '${(remainingMinutes ~/ 60).toString().padLeft(2, '0')}:${(remainingMinutes % 60).toString().padLeft(2, '0')}:${secondsDisplay.toString().padLeft(2, '0')}';
    
    final timeTextPainter = TextPainter(
      text: TextSpan(
        text: timeText,
        style: TextStyle(
          fontSize: totalMinutesDisplay < 60 ? 48 : 40,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    timeTextPainter.layout();
    timeTextPainter.paint(
      canvas,
      Offset(
        center.dx - timeTextPainter.width / 2,
        center.dy - timeTextPainter.height / 2,
      ),
    );

    // 绘制倒计时指针（从选择位置倒转回12点）
    final pointerPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final pointerEnd = Offset(
      center.dx + (radius * 0.65) * math.cos(currentAngle),
      center.dy + (radius * 0.65) * math.sin(currentAngle),
    );
    canvas.drawLine(center, pointerEnd, pointerPaint);

    // 绘制指针末端圆点
    final pointerDotPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pointerEnd, 8, pointerDotPaint);
    
    // 绘制中心圆点
    canvas.drawCircle(center, 6, pointerDotPaint);
  }

  @override
  bool shouldRepaint(_ClockFacePainter oldDelegate) {
    return oldDelegate.selectedMinutes != selectedMinutes ||
        oldDelegate.remainingTime != remainingTime ||
        oldDelegate.totalTime != totalTime ||
        oldDelegate.isCountdownMode != isCountdownMode;
  }
}

