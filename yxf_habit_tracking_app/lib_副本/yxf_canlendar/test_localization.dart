import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'lib/core/utils/date_util.dart';

/// 本地化测试文件
/// 用于验证日期格式化和本地化数据是否正确初始化
void main() async {
  // 初始化本地化数据
  await initializeDateFormatting('zh_CN', null);
  await initializeDateFormatting('en_US', null);
  
  print('=== 本地化测试开始 ===');
  
  final now = DateTime.now();
  
  // 测试基础 DateFormat
  try {
    final formatter1 = DateFormat('yyyy-MM-dd', 'zh_CN');
    print('基础日期格式化: ${formatter1.format(now)}');
    
    final formatter2 = DateFormat('M月d日 EEEE', 'zh_CN');
    print('中文日期格式化: ${formatter2.format(now)}');
    
    final formatter3 = DateFormat('MMM', 'zh_CN');
    print('中文月份格式化: ${formatter3.format(now)}');
  } catch (e) {
    print('DateFormat 错误: $e');
  }
  
  // 测试 DateUtil 工具类
  try {
    print('DateUtil.formatDate: ${DateUtil.formatDate(now)}');
    print('DateUtil.formatTime: ${DateUtil.formatTime(now)}');
    print('DateUtil.formatDateTime: ${DateUtil.formatDateTime(now)}');
  } catch (e) {
    print('DateUtil 错误: $e');
  }
  
  print('=== 本地化测试完成 ===');
}