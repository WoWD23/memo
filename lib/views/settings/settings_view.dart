import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../repositories/check_in_repository.dart';
import '../../repositories/pomodoro_repository.dart';

/// 设置视图
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final CheckInRepository _checkInRepository = CheckInRepository();
  final PomodoroRepository _pomodoroRepository = PomodoroRepository();

  ThemeMode _themeMode = ThemeMode.system;
  int _defaultPomodoroMinutes = 25;

  int _totalCheckIns = 0;
  int _totalPomodoros = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadStatistics();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final themeModeString = prefs.getString('theme_mode') ?? 'system';
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == themeModeString,
        orElse: () => ThemeMode.system,
      );
      _defaultPomodoroMinutes = prefs.getInt('default_pomodoro_minutes') ?? 25;
    });
  }

  Future<void> _loadStatistics() async {
    _totalCheckIns = await _checkInRepository.getCount();
    _totalPomodoros = await _pomodoroRepository.getTotalCompletedCount();
    setState(() {});
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    setState(() => _themeMode = mode);
  }

  Future<void> _savePomodoroMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('default_pomodoro_minutes', minutes);
    setState(() => _defaultPomodoroMinutes = minutes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                const Text(
                  '设置',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // 统计卡片
                _buildStatisticsCard(),
                const SizedBox(height: 16),

                // 外观设置
                _buildAppearanceSection(),
                const SizedBox(height: 16),

                // 番茄钟设置
                _buildPomodoroSection(),
                const SizedBox(height: 16),

                // 关于
                _buildAboutSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 统计卡片
  Widget _buildStatisticsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '使用统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle,
                label: '总打卡',
                value: '$_totalCheckIns',
              ),
              _buildStatItem(
                icon: Icons.timer,
                label: '总番茄钟',
                value: '$_totalPomodoros',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// 外观设置
  Widget _buildAppearanceSection() {
    return _buildSection(
      title: '外观',
      children: [
        _buildSettingTile(
          icon: Icons.palette,
          title: '主题模式',
          trailing: DropdownButton<ThemeMode>(
            value: _themeMode,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('跟随系统'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('浅色'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('深色'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                _saveThemeMode(value);
                _showMessage('主题设置将在重启应用后生效');
              }
            },
          ),
        ),
      ],
    );
  }

  /// 番茄钟设置
  Widget _buildPomodoroSection() {
    return _buildSection(
      title: '番茄钟',
      children: [
        _buildSettingTile(
          icon: Icons.timer,
          title: '默认时长',
          subtitle: '$_defaultPomodoroMinutes 分钟',
          onTap: () => _showPomodoroMinutesDialog(),
        ),
      ],
    );
  }

  /// 关于
  Widget _buildAboutSection() {
    return _buildSection(
      title: '关于',
      children: [
        _buildSettingTile(
          icon: Icons.info,
          title: '版本',
          trailing: const Text('1.0.0'),
        ),
        _buildSettingTile(
          icon: Icons.description,
          title: '关于 Memo',
          onTap: () => _showAboutDialog(),
        ),
      ],
    );
  }

  /// 构建设置分组
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// 构建设置项
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  /// 显示番茄钟时长设置对话框
  Future<void> _showPomodoroMinutesDialog() async {
    int selectedMinutes = _defaultPomodoroMinutes;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置默认番茄钟时长'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$selectedMinutes 分钟',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: selectedMinutes.toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                label: '$selectedMinutes 分钟',
                onChanged: (value) {
                  setState(() {
                    selectedMinutes = value.toInt();
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedMinutes),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      await _savePomodoroMinutes(result);
      _showMessage('默认番茄钟时长已设置为 $result 分钟');
    }
  }

  /// 显示关于对话框
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于 Memo'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('版本: 1.0.0'),
            SizedBox(height: 16),
            Text('一款简洁优雅的打卡和番茄钟应用，帮助你养成良好的习惯，提高专注力。'),
            SizedBox(height: 16),
            Text(
              '功能特点：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• 每日打卡记录'),
            Text('• 番茄钟专注计时'),
            Text('• 日历视图统计'),
            Text('• 数据本地存储'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示消息
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

