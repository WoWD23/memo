import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 数字时间显示组件
class TimeDisplay extends StatelessWidget {
  final int hour;
  final int minute;
  final bool isAM;
  final Function(bool) onAMPMChanged;

  const TimeDisplay({
    super.key,
    required this.hour,
    required this.minute,
    required this.isAM,
    required this.onAMPMChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 小时显示（浅紫色背景）
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryVeryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            hour.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 分隔符
        const Text(
          ':',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        // 分钟显示（白色背景）
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.divider,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            minute.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // AM/PM 按钮
        Column(
          children: [
            // AM 按钮
            GestureDetector(
              onTap: () => onAMPMChanged(true),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isAM ? AppColors.pinkLight : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAM ? AppColors.pink : AppColors.divider,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'AM',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isAM ? AppColors.pink : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // PM 按钮
            GestureDetector(
              onTap: () => onAMPMChanged(false),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: !isAM ? AppColors.pinkLight : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: !isAM ? AppColors.pink : AppColors.divider,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'PM',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: !isAM ? AppColors.pink : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

