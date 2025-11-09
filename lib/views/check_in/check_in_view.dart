import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/check_in/check_in_view_model.dart';
import '../../core/theme/app_colors.dart';

/// 打卡视图
class CheckInView extends StatefulWidget {
  const CheckInView({super.key});

  @override
  State<CheckInView> createState() => _CheckInViewState();
}

class _CheckInViewState extends State<CheckInView> {
  late CheckInViewModel _viewModel;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = CheckInViewModel();
    _viewModel.initialize();
    _viewModel.loadRecentCheckIns();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Consumer<CheckInViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading && viewModel.todayCheckIn == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await viewModel.initialize();
                  await viewModel.loadRecentCheckIns();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 标题
                        const Text(
                          '每日打卡',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 统计卡片
                        _buildStatisticsCard(viewModel),
                        const SizedBox(height: 16),

                        // 打卡按钮/状态卡片
                        _buildCheckInCard(viewModel),
                        const SizedBox(height: 24),

                        // 最近打卡记录
                        _buildRecentCheckIns(viewModel),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 统计卡片
  Widget _buildStatisticsCard(CheckInViewModel viewModel) {
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.local_fire_department,
            label: '连续打卡',
            value: '${viewModel.streakDays}天',
            color: Colors.orange,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            label: '总打卡',
            value: '${viewModel.totalCount}天',
            color: AppColors.checkIn,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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

  /// 打卡卡片
  Widget _buildCheckInCard(CheckInViewModel viewModel) {
    final hasCheckedIn = viewModel.hasCheckedInToday;

    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          // 日期显示
          Text(
            _formatDate(DateTime.now()),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // 打卡按钮或状态
          if (!hasCheckedIn)
            _buildCheckInButton(viewModel)
          else
            _buildCheckedInStatus(viewModel),
        ],
      ),
    );
  }

  /// 打卡按钮
  Widget _buildCheckInButton(CheckInViewModel viewModel) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _showCheckInDialog(viewModel),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.checkIn,
            foregroundColor: Colors.white,
            minimumSize: const Size(200, 200),
            shape: const CircleBorder(),
            elevation: 8,
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 64),
              SizedBox(height: 12),
              Text(
                '打卡',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '点击按钮完成今日打卡',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 已打卡状态
  Widget _buildCheckedInStatus(CheckInViewModel viewModel) {
    final checkIn = viewModel.todayCheckIn!;

    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.checkIn.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.checkIn,
              ),
              const SizedBox(height: 12),
              const Text(
                '已打卡',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.checkIn,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(checkIn.createdAt),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (checkIn.note != null && checkIn.note!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.note, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    checkIn.note!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 最近打卡记录
  Widget _buildRecentCheckIns(CheckInViewModel viewModel) {
    if (viewModel.recentCheckIns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                '暂无打卡记录',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '打卡历史',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.recentCheckIns.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
            itemBuilder: (context, index) {
              final checkIn = viewModel.recentCheckIns[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.checkIn.withOpacity(0.1),
                  child: const Icon(Icons.check, color: AppColors.checkIn),
                ),
                title: Text(
                  _formatDate(checkIn.date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: checkIn.note != null && checkIn.note!.isNotEmpty
                    ? Text(checkIn.note!)
                    : null,
                trailing: Text(
                  _formatTime(checkIn.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 显示打卡对话框
  Future<void> _showCheckInDialog(CheckInViewModel viewModel) async {
    _noteController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('打卡'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('今天过得怎么样？'),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: '添加备注（可选）',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.checkIn,
              foregroundColor: Colors.white,
            ),
            child: const Text('打卡'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final note = _noteController.text.trim();
      final success = await viewModel.checkIn(
        note: note.isEmpty ? null : note,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '打卡成功！' : '打卡失败，请重试'),
            backgroundColor: success ? AppColors.checkIn : Colors.red,
          ),
        );
      }
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}年${date.month}月${date.day}日 $weekday';
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

