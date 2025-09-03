/// 日期时间工具类，处理日期和时间操作，如格式化、比较等
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateUtil {
  // 常用日期格式
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultTimeFormat = 'HH:mm';
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String chineseDateFormat = 'yyyy年MM月dd日';
  static const String chineseTimeFormat = 'HH时mm分';
  static const String displayDateFormat = 'MM月dd日';
  static const String weekdayFormat = 'EEEE';

  /// 格式化日期
  static String formatDate(DateTime date, {String format = defaultDateFormat}) {
    try {
      final formatter = DateFormat(format, 'zh_CN');
      return formatter.format(date);
    } catch (e) {
      // 如果本地化数据未初始化，使用基础格式
      try {
        final basicFormatter = DateFormat(format);
        return basicFormatter.format(date);
      } catch (e2) {
        // 最后的降级处理
        return date.toString().split(' ')[0];
      }
    }
  }

  /// 格式化时间
  static String formatTime(DateTime time, {String format = defaultTimeFormat}) {
    try {
      final formatter = DateFormat(format, 'zh_CN');
      return formatter.format(time);
    } catch (e) {
      // 如果本地化数据未初始化，使用基础格式
      try {
        final basicFormatter = DateFormat(format);
        return basicFormatter.format(time);
      } catch (e2) {
        // 最后的降级处理
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }
    }
  }

  /// 格式化日期时间
  static String formatDateTime(DateTime dateTime, {String format = defaultDateTimeFormat}) {
    try {
      final formatter = DateFormat(format, 'zh_CN');
      return formatter.format(dateTime);
    } catch (e) {
      // 如果本地化数据未初始化，使用基础格式
      try {
        final basicFormatter = DateFormat(format);
        return basicFormatter.format(dateTime);
      } catch (e2) {
        // 最后的降级处理
        return dateTime.toString();
      }
    }
  }

  /// 解析日期字符串，支持多种格式
  static DateTime? parseDate(String dateStr, {String format = defaultDateFormat}) {
    if (dateStr.trim().isEmpty) return null;
    
    // 常用日期格式列表
    final formats = [
      format, // 用户指定的格式
      defaultDateFormat, // yyyy-MM-dd
      'yyyy/MM/dd',
      'MM/dd/yyyy',
      'dd/MM/yyyy',
      'M/d/yyyy', // DateFormat.yMd() 格式
      'yyyy-M-d',
      'yyyy年MM月dd日',
      chineseDateFormat,
    ];
    
    for (final fmt in formats) {
      try {
        final formatter = DateFormat(fmt);
        return formatter.parse(dateStr.trim());
      } catch (e) {
        // 继续尝试下一个格式
        continue;
      }
    }
    
    // 如果所有格式都失败，尝试DateTime.parse
    try {
      return DateTime.parse(dateStr.trim());
    } catch (e) {
      return null;
    }
  }

  /// 判断是否为今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 判断是否为昨天
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// 判断是否为明天
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// 判断是否为本周
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// 判断是否为本月
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// 判断是否为本年
  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// 获取相对时间描述
  static String getRelativeTimeDescription(DateTime date) {
    if (isToday(date)) {
      return '今天';
    } else if (isYesterday(date)) {
      return '昨天';
    } else if (isTomorrow(date)) {
      return '明天';
    } else if (isThisWeek(date)) {
      return formatDate(date, format: weekdayFormat);
    } else if (isThisYear(date)) {
      return formatDate(date, format: displayDateFormat);
    } else {
      return formatDate(date, format: defaultDateFormat);
    }
  }

  /// 获取两个日期之间的天数差
  static int getDaysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays;
  }

  /// 获取月份的天数
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 获取月份的第一天
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// 获取月份的最后一天
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// 获取周的第一天（周一）
  static DateTime getFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// 获取周的最后一天（周日）
  static DateTime getLastDayOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  /// 判断是否为工作日
  static bool isWeekday(DateTime date) {
    return date.weekday >= 1 && date.weekday <= 5;
  }

  /// 判断是否为周末
  static bool isWeekend(DateTime date) {
    return date.weekday == 6 || date.weekday == 7;
  }

  /// 获取特殊日期问候语
  static String? getSpecialDateGreeting(DateTime date) {
    final month = date.month;
    final day = date.day;
    
    // 国家法定节假日
    if (month == 1 && day == 1) return '元旦快乐！';
    if (month == 5 && day == 1) return '劳动节快乐！';
    if (month == 10 && day == 1) return '国庆节快乐！';
    
    // 传统节日（简化处理，实际应考虑农历）
    if (month == 2 && day == 14) return '情人节快乐！';
    if (month == 3 && day == 8) return '妇女节快乐！';
    if (month == 5 && day == 4) return '青年节快乐！';
    if (month == 6 && day == 1) return '儿童节快乐！';
    if (month == 9 && day == 10) return '教师节快乐！';
    if (month == 12 && day == 25) return '圣诞节快乐！';
    
    // 学校特殊日期
    if (month == 10 && day == 27) return '校庆快乐！';
    
    return null;
  }

  /// 获取时间段描述
  static String getTimeOfDayDescription(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) {
      return '上午';
    } else if (hour >= 12 && hour < 18) {
      return '下午';
    } else if (hour >= 18 && hour < 22) {
      return '晚上';
    } else {
      return '深夜';
    }
  }

  /// 创建今天的日期（时间为00:00:00）
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 创建明天的日期
  static DateTime tomorrow() {
    return today().add(const Duration(days: 1));
  }

  /// 创建昨天的日期
  static DateTime yesterday() {
    return today().subtract(const Duration(days: 1));
  }
}

/// 时间工具类，处理时间操作，如验证时间合法性、格式化等
class TimeUtil {
  // 常用时间格式
  static const String format12Hour = 'h:mm a';
  static const String format24Hour = 'HH:mm';
  static const String formatWithSeconds = 'HH:mm:ss';
  
  /// 验证时间是否合法：开始时间必须早于结束时间，且符合 AM/PM 规则
  static bool validateTime({
    required String startTime,
    required String endTime,
  }) {
    try {
      final start = parseTimeString(startTime);
      final end = parseTimeString(endTime);
      
      if (start == null || end == null) {
        return false;
      }
      
      return start.isBefore(end);
    } catch (e) {
      return false;
    }
  }

  /// 验证时间范围是否合理（不能跨天，且持续时间合理）
  static bool validateTimeRange({
    required String startTime,
    required String endTime,
    int maxDurationHours = 12,
  }) {
    if (!validateTime(startTime: startTime, endTime: endTime)) {
      return false;
    }
    
    final start = parseTimeString(startTime)!;
    final end = parseTimeString(endTime)!;
    final duration = end.difference(start);
    
    return duration.inHours <= maxDurationHours;
  }

  /// 将时间字符串解析为 DateTime（支持多种格式）
  static DateTime? parseTimeString(String timeStr) {
    try {
      // 处理 AM/PM 格式
      if (timeStr.toUpperCase().contains('AM') || timeStr.toUpperCase().contains('PM')) {
        return _parseAmPmTime(timeStr);
      }
      
      // 处理 24小时格式
      if (timeStr.contains(':')) {
        return _parse24HourTime(timeStr);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 解析 AM/PM 格式时间
  static DateTime? _parseAmPmTime(String time) {
    try {
      final parts = time.trim().split(' ');
      if (parts.length != 2) return null;
      
      final hourMinute = parts[0].split(':');
      if (hourMinute.length != 2) return null;
      
      final hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);
      final isPm = parts[1].toUpperCase() == 'PM';
      
      if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
        return null;
      }
      
      final adjustedHour = isPm ? (hour == 12 ? 12 : hour + 12) : (hour == 12 ? 0 : hour);
      
      return DateTime(2000, 1, 1, adjustedHour, minute);
    } catch (e) {
      return null;
    }
  }

  /// 解析 24小时格式时间
  static DateTime? _parse24HourTime(String time) {
    try {
      final parts = time.trim().split(':');
      if (parts.length < 2 || parts.length > 3) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final second = parts.length == 3 ? int.parse(parts[2]) : 0;
      
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59 || second < 0 || second > 59) {
        return null;
      }
      
      return DateTime(2000, 1, 1, hour, minute, second);
    } catch (e) {
      return null;
    }
  }

  /// 格式化时间为 AM/PM 格式
  static String formatToAmPm(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    
    if (hour == 0) {
      return '12:${minute.toString().padLeft(2, '0')} AM';
    } else if (hour < 12) {
      return '${hour}:${minute.toString().padLeft(2, '0')} AM';
    } else if (hour == 12) {
      return '12:${minute.toString().padLeft(2, '0')} PM';
    } else {
      return '${hour - 12}:${minute.toString().padLeft(2, '0')} PM';
    }
  }

  /// 格式化时间为 24小时格式
  static String formatTo24Hour(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化时间为带秒的格式
   static String formatTimeWithSeconds(DateTime time) {
     return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
   }

  /// 获取时间差描述
  static String getTimeDifferenceDescription(DateTime start, DateTime end) {
    final difference = end.difference(start);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天${difference.inHours % 24}小时';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时${difference.inMinutes % 60}分钟';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟';
    } else {
      return '${difference.inSeconds}秒';
    }
  }

  /// 计算两个时间之间的分钟数
  static int getMinutesBetween(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  /// 添加分钟到时间
  static DateTime addMinutes(DateTime time, int minutes) {
    return time.add(Duration(minutes: minutes));
  }

  /// 添加小时到时间
  static DateTime addHours(DateTime time, int hours) {
    return time.add(Duration(hours: hours));
  }

  /// 判断时间是否在指定范围内
  static bool isTimeInRange(DateTime time, DateTime start, DateTime end) {
    return time.isAfter(start) && time.isBefore(end) || 
           time.isAtSameMomentAs(start) || 
           time.isAtSameMomentAs(end);
  }

  /// 获取当前时间的 AM/PM 格式
  static String getCurrentTimeAmPm() {
    return formatToAmPm(DateTime.now());
  }

  /// 获取当前时间的 24小时格式
  static String getCurrentTime24Hour() {
    return formatTo24Hour(DateTime.now());
  }

  /// 创建指定时间的 DateTime 对象（今天的日期）
  static DateTime createTimeToday(int hour, int minute, [int second = 0]) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute, second);
  }

  /// 判断是否为有效的时间格式
  static bool isValidTimeFormat(String timeStr) {
    return parseTimeString(timeStr) != null;
  }

  /// 获取时间的小时部分
  static int getHour(String timeStr) {
    final time = parseTimeString(timeStr);
    return time?.hour ?? 0;
  }

  /// 获取时间的分钟部分
  static int getMinute(String timeStr) {
    final time = parseTimeString(timeStr);
    return time?.minute ?? 0;
  }

  /// 将时间字符串解析为 DateTime（已弃用，使用 parseTimeString 代替）
  @Deprecated('Use parseTimeString instead')
  static DateTime _parseTime(String time) {
    final parsed = parseTimeString(time);
    return parsed ?? DateTime(0, 1, 1);
  }
}
