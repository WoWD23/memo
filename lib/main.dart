import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'views/main/main_view.dart';
import 'view_models/pomodoro/pomodoro_view_model.dart';
import 'view_models/navigation_view_model.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化通知服务
  await NotificationService.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 全局提供NavigationViewModel，用于跨页面导航
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        // 全局提供PomodoroViewModel，这样MainView可以监听锁定状态
        ChangeNotifierProvider(create: (_) => PomodoroViewModel()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
