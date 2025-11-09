import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// 通知服务
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  NotificationService._init();

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      final result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      _isInitialized = result ?? false;
      
      if (_isInitialized) {
        // 请求权限（Android 13+）
        await _requestPermissions();
        debugPrint('通知服务初始化成功');
      }
    } catch (e) {
      debugPrint('通知服务初始化失败: $e');
    }
  }

  /// 请求通知权限
  Future<void> _requestPermissions() async {
    try {
      // Android 13+ 需要请求权限
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      // iOS 权限请求
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      debugPrint('请求通知权限失败: $e');
    }
  }

  /// 显示番茄钟完成通知
  Future<void> showPomodoroCompleteNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      '番茄钟通知',
      channelDescription: '番茄钟完成提醒',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        1,
        '番茄钟完成！',
        '恭喜！你已完成一个番茄钟，休息一下吧 🍅',
        details,
      );
    } catch (e) {
      debugPrint('显示番茄钟完成通知失败: $e');
    }
  }

  /// 显示休息结束通知
  Future<void> showBreakEndNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      '番茄钟通知',
      channelDescription: '休息结束提醒',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        2,
        '休息结束！',
        '准备好开始下一个番茄钟了吗？💪',
        details,
      );
    } catch (e) {
      debugPrint('显示休息结束通知失败: $e');
    }
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('取消通知失败: $e');
    }
  }

  /// 通知点击回调
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('通知被点击: ${response.payload}');
    // 这里可以处理通知点击事件，比如跳转到特定页面
  }
}

