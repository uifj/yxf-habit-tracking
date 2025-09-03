// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import 'dart:developer';
// import '../../core/error/exceptions.dart';

// /// 通知帮助类
// /// 负责管理本地通知的初始化、调度和取消
// class NotifyHelper {
//   static NotifyHelper? _instance;
//   static NotifyHelper get instance => _instance ??= NotifyHelper._internal();

//   NotifyHelper._internal();

//   factory NotifyHelper() => instance;

//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   bool _isInitialized = false;

//   /// 获取初始化状态
//   bool get isInitialized => _isInitialized;

//   /// 初始化通知系统
//   Future<void> initializeNotification() async {
//     try {
//       if (_isInitialized) {
//         log('Notification system already initialized');
//         return;
//       }

//       log('Initializing notification system');

//       // 初始化时区数据
//       tz.initializeTimeZones();

//       // iOS设置
//       const DarwinInitializationSettings initializationSettingsIOS =
//           DarwinInitializationSettings(
//         requestSoundPermission: true,
//         requestBadgePermission: true,
//         requestAlertPermission: true,
//         onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
//       );

//       // Android设置
//       const AndroidInitializationSettings initializationSettingsAndroid =
//           AndroidInitializationSettings('@mipmap/ic_launcher');

//       // 组合设置
//       const InitializationSettings initializationSettings =
//           InitializationSettings(
//         iOS: initializationSettingsIOS,
//         android: initializationSettingsAndroid,
//       );

//       // 初始化插件
//       final result = await _flutterLocalNotificationsPlugin.initialize(
//         initializationSettings,
//         onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
//       );

//       if (result == true) {
//         _isInitialized = true;
//         log('Notification system initialized successfully');

//         // 创建Android通知渠道
//         await _createNotificationChannel();
//       } else {
//         throw const NotificationException(
//           message: 'Failed to initialize notification system',
//           code: 5001,
//         );
//       }
//     } catch (e) {
//       log('Error initializing notification system: $e');
//       if (e is AppException) rethrow;
//       throw const NotificationException(
//         message: 'Failed to initialize notification system',
//         code: 5002,
//       );
//     }
//   }

//   /// 创建Android通知渠道
//   Future<void> _createNotificationChannel() async {
//     try {
//       const AndroidNotificationChannel channel = AndroidNotificationChannel(
//         'task_reminder_channel',
//         'Task Reminders',
//         description: 'Notifications for task reminders',
//         importance: Importance.high,
//         enableVibration: true,
//         playSound: true,
//       );

//       await _flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(channel);

//       log('Android notification channel created successfully');
//     } catch (e) {
//       log('Error creating notification channel: $e');
//       throw const NotificationException(
//         message: 'Failed to create notification channel',
//         code: 5003,
//       );
//     }
//   }

//   /// 请求iOS权限
//   Future<bool> requestIOSPermissions() async {
//     try {
//       final result = await _flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );

//       log('iOS permissions requested: $result');
//       return result ?? false;
//     } catch (e) {
//       log('Error requesting iOS permissions: $e');
//       return false;
//     }
//   }

//   /// 显示即时通知
//   Future<void> displayNotification({
//     required String title,
//     required String body,
//     int id = 0,
//     String? payload,
//   }) async {
//     try {
//       if (!_isInitialized) {
//         throw const NotificationException(
//           message: 'Notification system not initialized',
//           code: 5004,
//         );
//       }

//       log('Displaying notification: $title');

//       const AndroidNotificationDetails androidDetails =
//           AndroidNotificationDetails(
//         'task_reminder_channel',
//         'Task Reminders',
//         channelDescription: 'Notifications for task reminders',
//         importance: Importance.high,
//         priority: Priority.high,
//         enableVibration: true,
//         playSound: true,
//         icon: '@mipmap/ic_launcher',
//       );

//       const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );

//       const NotificationDetails platformChannelSpecifics = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       await _flutterLocalNotificationsPlugin.show(
//         id,
//         title,
//         body,
//         platformChannelSpecifics,
//         payload: payload,
//       );

//       log('Notification displayed successfully');
//     } catch (e) {
//       log('Error displaying notification: $e');
//       if (e is AppException) rethrow;
//       throw const NotificationException(
//         message: 'Failed to display notification',
//         code: 5005,
//       );
//     }
//   }

//   /// 调度定时通知
//   Future<void> scheduledNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledTime,
//     String? payload,
//   }) async {
//     try {
//       if (!_isInitialized) {
//         throw const NotificationException(
//           message: 'Notification system not initialized',
//           code: 5006,
//         );
//       }

//       // 检查时间是否在未来
//       if (scheduledTime.isBefore(DateTime.now())) {
//         log('Scheduled time is in the past, skipping notification');
//         return;
//       }

//       log('Scheduling notification for: $scheduledTime');

//       final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
//         scheduledTime,
//         tz.local,
//       );

//       const AndroidNotificationDetails androidDetails =
//           AndroidNotificationDetails(
//         'task_reminder_channel',
//         'Task Reminders',
//         channelDescription: 'Notifications for task reminders',
//         importance: Importance.high,
//         priority: Priority.high,
//         enableVibration: true,
//         playSound: true,
//         icon: '@mipmap/ic_launcher',
//       );

//       const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );

//       const NotificationDetails platformChannelSpecifics = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       await _flutterLocalNotificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         tzScheduledTime,
//         platformChannelSpecifics,
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         payload: payload,
//       );

//       log('Notification scheduled successfully for ID: $id');
//     } catch (e) {
//       log('Error scheduling notification: $e');
//       if (e is AppException) rethrow;
//       throw const NotificationException(
//         message: 'Failed to schedule notification',
//         code: 5007,
//       );
//     }
//   }

//   /// 取消指定通知
//   Future<void> cancelNotification(int id) async {
//     try {
//       if (!_isInitialized) {
//         log('Notification system not initialized, cannot cancel notification');
//         return;
//       }

//       await _flutterLocalNotificationsPlugin.cancel(id);
//       log('Notification cancelled for ID: $id');
//     } catch (e) {
//       log('Error cancelling notification: $e');
//       throw const NotificationException(
//         message: 'Failed to cancel notification',
//         code: 5008,
//       );
//     }
//   }

//   /// 取消所有通知
//   Future<void> cancelAllNotifications() async {
//     try {
//       if (!_isInitialized) {
//         log('Notification system not initialized, cannot cancel notifications');
//         return;
//       }

//       await _flutterLocalNotificationsPlugin.cancelAll();
//       log('All notifications cancelled');
//     } catch (e) {
//       log('Error cancelling all notifications: $e');
//       throw const NotificationException(
//         message: 'Failed to cancel all notifications',
//         code: 5009,
//       );
//     }
//   }

//   /// 获取待处理的通知
//   Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     try {
//       if (!_isInitialized) {
//         return [];
//       }

//       final pendingNotifications =
//           await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
//       log('Found ${pendingNotifications.length} pending notifications');
//       return pendingNotifications;
//     } catch (e) {
//       log('Error getting pending notifications: $e');
//       return [];
//     }
//   }

//   /// iOS本地通知回调
//   static void _onDidReceiveLocalNotification(
//     int id,
//     String? title,
//     String? body,
//     String? payload,
//   ) {
//     log('iOS local notification received: $title');
//   }

//   /// 通知响应回调
//   static void _onDidReceiveNotificationResponse(
//     NotificationResponse notificationResponse,
//   ) {
//     final String? payload = notificationResponse.payload;
//     log('Notification response received with payload: $payload');

//     // 这里可以处理通知点击事件
//     // 例如导航到特定页面或执行特定操作
//   }
// }
