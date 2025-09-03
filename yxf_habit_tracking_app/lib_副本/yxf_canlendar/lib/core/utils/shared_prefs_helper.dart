import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 辅助类
class SharedPrefsHelper {
  static SharedPrefsHelper? _instance;
  static SharedPreferences? _prefs;

  SharedPrefsHelper._internal();

  static SharedPrefsHelper get instance {
    _instance ??= SharedPrefsHelper._internal();
    return _instance!;
  }

  /// 初始化 SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 初始化数据库（兼容性方法）
  Future<void> initDb() async {
    await init();
  }

  /// 获取 SharedPreferences 实例
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // String 操作
  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  // Int 操作
  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  // Double 操作
  Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  // Bool 操作
  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  // StringList 操作
  Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  // 删除操作
  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  // 清空所有数据
  Future<bool> clear() async {
    return await prefs.clear();
  }

  // 检查是否包含某个键
  bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  // 获取所有键
  Set<String> getKeys() {
    return prefs.getKeys();
  }

  // 重新加载数据
  Future<void> reload() async {
    await prefs.reload();
  }
}