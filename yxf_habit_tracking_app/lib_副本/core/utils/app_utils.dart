import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 应用工具类
class AppUtils {
  AppUtils._();

  /// 生成随机字符串
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  /// 计算WPM（每分钟单词数）
  static double calculateWPM(int correctChars, Duration duration) {
    if (duration.inSeconds == 0) return 0.0;
    return (correctChars / 5.0) / (duration.inMinutes);
  }

  /// 计算准确率
  static double calculateAccuracy(int correctChars, int totalChars) {
    if (totalChars == 0) return 0.0;
    return (correctChars / totalChars) * 100;
  }

  /// 格式化时间
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 格式化日期
  static String formatDate(DateTime date,
      {String pattern = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(pattern).format(date);
  }

  /// 验证邮箱格式
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 验证手机号格式
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }

  /// 获取文件扩展名
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 深拷贝JSON对象
  static T deepCopy<T>(T object) {
    return jsonDecode(jsonEncode(object)) as T;
  }

  /// 防抖函数
  static Function debounce(Function func, Duration delay) {
    Timer? timer;
    return (List<dynamic> args) {
      timer?.cancel();
      timer = Timer(delay, () => Function.apply(func, args));
    };
  }

  /// 节流函数
  static Function throttle(Function func, Duration delay) {
    bool isThrottled = false;
    return (List<dynamic> args) {
      if (!isThrottled) {
        Function.apply(func, args);
        isThrottled = true;
        Timer(delay, () => isThrottled = false);
      }
    };
  }

  /// 获取随机颜色
  static Color getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  /// 判断是否为深色
  static bool isDarkColor(Color color) {
    return color.computeLuminance() < 0.5;
  }

  /// 获取对比色
  static Color getContrastColor(Color color) {
    return isDarkColor(color) ? Colors.white : Colors.black;
  }

  /// 混合颜色
  static Color blendColors(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio) ?? color1;
  }

  /// 将十六进制字符串转换为颜色
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// 将颜色转换为十六进制字符串
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// 获取屏幕尺寸
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// 判断是否为平板
  static bool isTablet(BuildContext context) {
    final size = getScreenSize(context);
    return size.shortestSide >= 600;
  }

  /// 判断是否为桌面端
  static bool isDesktop(BuildContext context) {
    final size = getScreenSize(context);
    return size.width >= 1024;
  }

  /// 获取安全区域
  static EdgeInsets getSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// 隐藏键盘
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// 显示SnackBar
  static void showSnackBar(BuildContext context, String message,
      {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// 显示确认对话框
  static Future<bool?> showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
