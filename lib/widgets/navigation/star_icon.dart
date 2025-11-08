import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 自定义星形图标
class StarIcon extends StatelessWidget {
  final bool isSelected;
  final double size;

  const StarIcon({
    super.key,
    required this.isSelected,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      // 选中状态：实心星形（白色，因为背景是紫色）
      return CustomPaint(
        size: Size(size, size),
        painter: _SolidStarPainter(color: Colors.white),
      );
    } else {
      // 未选中状态：星形轮廓 + 内部实心星形
      return CustomPaint(
        size: Size(size, size),
        painter: _OutlinedStarPainter(),
      );
    }
  }
}

/// 实心星形绘制
class _SolidStarPainter extends CustomPainter {
  final Color color;

  _SolidStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    _drawStar(canvas, size, paint);
  }

  @override
  bool shouldRepaint(_SolidStarPainter oldDelegate) =>
      oldDelegate.color != color;

  void _drawStar(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final path = Path();

    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

/// 星形轮廓 + 内部实心星形绘制
class _OutlinedStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4; // 内部星形较小

    // 绘制外部星形轮廓
    final outlinePaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final outlinePath = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - (math.pi / 2);
      final x = center.dx + outerRadius * math.cos(angle);
      final y = center.dy + outerRadius * math.sin(angle);
      if (i == 0) {
        outlinePath.moveTo(x, y);
      } else {
        outlinePath.lineTo(x, y);
      }
    }
    outlinePath.close();
    canvas.drawPath(outlinePath, outlinePaint);

    // 绘制内部实心星形
    final innerPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;

    final innerPath = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - (math.pi / 2);
      final x = center.dx + innerRadius * math.cos(angle);
      final y = center.dy + innerRadius * math.sin(angle);
      if (i == 0) {
        innerPath.moveTo(x, y);
      } else {
        innerPath.lineTo(x, y);
      }
    }
    innerPath.close();
    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(_OutlinedStarPainter oldDelegate) => false;
}

