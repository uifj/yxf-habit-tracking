import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../logging/app_logger.dart';

/// 缓存条目类
class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String key;

  CacheEntry({
    required this.data,
    required this.createdAt,
    required this.key,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'key': key,
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json, String key) {
    return CacheEntry<T>(
      data: json['data'] as T,
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      key: key,
    );
  }
}

/// 企业级缓存管理器
/// 统一管理应用的内存缓存和持久化缓存
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // 内存缓存
  static final Map<String, CacheEntry> _memoryCache = {};
  static SharedPreferences? _prefs;

  /// 初始化缓存管理器
  static Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('Cache manager initialized', tag: 'CACHE');
      
      // 清理过期的持久化缓存
      await _cleanExpiredPersistentCache();
    } catch (e) {
      AppLogger.error('Failed to initialize cache manager', tag: 'CACHE', error: e);
    }
  }

  /// 设置内存缓存
  static void setMemoryCache<T>(
    String key,
    T data, {
    Duration? expiration,
  }) {
    try {
      final entry = CacheEntry<T>(
        data: data,
        createdAt: DateTime.now(),
        key: key,
        expiresAt: expiration != null ? DateTime.now().add(expiration) : null,
      );
      
      _memoryCache[key] = entry;
      AppLogger.debug('Memory cache set: $key', tag: 'CACHE');
      
      // 检查缓存大小限制
      _checkMemoryCacheSize();
    } catch (e) {
      AppLogger.error('Failed to set memory cache: $key', tag: 'CACHE', error: e);
    }
  }

  /// 获取内存缓存
  static T? getMemoryCache<T>(String key) {
    try {
      final entry = _memoryCache[key];
      if (entry == null) {
        AppLogger.debug('Memory cache miss: $key', tag: 'CACHE');
        return null;
      }
      
      if (entry.isExpired) {
        _memoryCache.remove(key);
        AppLogger.debug('Memory cache expired: $key', tag: 'CACHE');
        return null;
      }
      
      AppLogger.debug('Memory cache hit: $key', tag: 'CACHE');
      return entry.data as T;
    } catch (e) {
      AppLogger.error('Failed to get memory cache: $key', tag: 'CACHE', error: e);
      return null;
    }
  }

  /// 设置持久化缓存
  static Future<bool> setPersistentCache<T>(
    String key,
    T data, {
    Duration? expiration,
  }) async {
    try {
      if (_prefs == null) {
        AppLogger.warning('SharedPreferences not initialized', tag: 'CACHE');
        return false;
      }
      
      final entry = CacheEntry<T>(
        data: data,
        createdAt: DateTime.now(),
        key: key,
        expiresAt: expiration != null ? DateTime.now().add(expiration) : null,
      );
      
      final jsonString = jsonEncode(entry.toJson());
      final success = await _prefs!.setString(_getPersistentKey(key), jsonString);
      
      if (success) {
        AppLogger.debug('Persistent cache set: $key', tag: 'CACHE');
      } else {
        AppLogger.warning('Failed to set persistent cache: $key', tag: 'CACHE');
      }
      
      return success;
    } catch (e) {
      AppLogger.error('Failed to set persistent cache: $key', tag: 'CACHE', error: e);
      return false;
    }
  }

  /// 获取持久化缓存
  static Future<T?> getPersistentCache<T>(String key) async {
    try {
      if (_prefs == null) {
        AppLogger.warning('SharedPreferences not initialized', tag: 'CACHE');
        return null;
      }
      
      final jsonString = _prefs!.getString(_getPersistentKey(key));
      if (jsonString == null) {
        AppLogger.debug('Persistent cache miss: $key', tag: 'CACHE');
        return null;
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final entry = CacheEntry<T>.fromJson(json, key);
      
      if (entry.isExpired) {
        await _prefs!.remove(_getPersistentKey(key));
        AppLogger.debug('Persistent cache expired: $key', tag: 'CACHE');
        return null;
      }
      
      AppLogger.debug('Persistent cache hit: $key', tag: 'CACHE');
      return entry.data;
    } catch (e) {
      AppLogger.error('Failed to get persistent cache: $key', tag: 'CACHE', error: e);
      return null;
    }
  }

  /// 删除内存缓存
  static bool removeMemoryCache(String key) {
    try {
      final removed = _memoryCache.remove(key) != null;
      if (removed) {
        AppLogger.debug('Memory cache removed: $key', tag: 'CACHE');
      }
      return removed;
    } catch (e) {
      AppLogger.error('Failed to remove memory cache: $key', tag: 'CACHE', error: e);
      return false;
    }
  }

  /// 删除持久化缓存
  static Future<bool> removePersistentCache(String key) async {
    try {
      if (_prefs == null) return false;
      
      final success = await _prefs!.remove(_getPersistentKey(key));
      if (success) {
        AppLogger.debug('Persistent cache removed: $key', tag: 'CACHE');
      }
      return success;
    } catch (e) {
      AppLogger.error('Failed to remove persistent cache: $key', tag: 'CACHE', error: e);
      return false;
    }
  }

  /// 清空内存缓存
  static void clearMemoryCache() {
    try {
      final count = _memoryCache.length;
      _memoryCache.clear();
      AppLogger.info('Memory cache cleared ($count items)', tag: 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to clear memory cache', tag: 'CACHE', error: e);
    }
  }

  /// 清空持久化缓存
  static Future<void> clearPersistentCache() async {
    try {
      if (_prefs == null) return;
      
      final keys = _prefs!.getKeys().where((key) => key.startsWith('cache_')).toList();
      int removedCount = 0;
      
      for (final key in keys) {
        if (await _prefs!.remove(key)) {
          removedCount++;
        }
      }
      
      AppLogger.info('Persistent cache cleared ($removedCount items)', tag: 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to clear persistent cache', tag: 'CACHE', error: e);
    }
  }

  /// 清空所有缓存
  static Future<void> clearAllCache() async {
    clearMemoryCache();
    await clearPersistentCache();
    AppLogger.info('All cache cleared', tag: 'CACHE');
  }

  /// 获取缓存统计信息
  static Map<String, dynamic> getCacheStats() {
    final memoryCount = _memoryCache.length;
    final memoryExpiredCount = _memoryCache.values.where((entry) => entry.isExpired).length;
    
    return {
      'memory_cache_count': memoryCount,
      'memory_cache_expired_count': memoryExpiredCount,
      'memory_cache_active_count': memoryCount - memoryExpiredCount,
    };
  }

  /// 清理过期的内存缓存
  static void cleanExpiredMemoryCache() {
    try {
      final expiredKeys = _memoryCache.entries
          .where((entry) => entry.value.isExpired)
          .map((entry) => entry.key)
          .toList();
      
      for (final key in expiredKeys) {
        _memoryCache.remove(key);
      }
      
      if (expiredKeys.isNotEmpty) {
        AppLogger.info('Cleaned ${expiredKeys.length} expired memory cache entries', tag: 'CACHE');
      }
    } catch (e) {
      AppLogger.error('Failed to clean expired memory cache', tag: 'CACHE', error: e);
    }
  }

  /// 清理过期的持久化缓存
  static Future<void> _cleanExpiredPersistentCache() async {
    try {
      if (_prefs == null) return;
      
      final keys = _prefs!.getKeys().where((key) => key.startsWith('cache_')).toList();
      int removedCount = 0;
      
      for (final key in keys) {
        final jsonString = _prefs!.getString(key);
        if (jsonString != null) {
          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            final entry = CacheEntry.fromJson(json, key);
            
            if (entry.isExpired) {
              await _prefs!.remove(key);
              removedCount++;
            }
          } catch (e) {
            // 如果解析失败，删除损坏的缓存条目
            await _prefs!.remove(key);
            removedCount++;
          }
        }
      }
      
      if (removedCount > 0) {
        AppLogger.info('Cleaned $removedCount expired persistent cache entries', tag: 'CACHE');
      }
    } catch (e) {
      AppLogger.error('Failed to clean expired persistent cache', tag: 'CACHE', error: e);
    }
  }

  /// 检查内存缓存大小限制
  static void _checkMemoryCacheSize() {
    const maxSize = 1000; // 最大缓存条目数
    
    if (_memoryCache.length > maxSize) {
      // 删除最旧的缓存条目
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
      
      final toRemove = sortedEntries.take(_memoryCache.length - maxSize);
      for (final entry in toRemove) {
        _memoryCache.remove(entry.key);
      }
      
      AppLogger.info('Memory cache size limit reached, removed ${toRemove.length} oldest entries', tag: 'CACHE');
    }
  }

  /// 获取持久化缓存键名
  static String _getPersistentKey(String key) {
    return 'cache_$key';
  }

  /// 打印缓存统计信息
  static void printCacheStats() {
    if (AppConfig.isDebugMode) {
      final stats = getCacheStats();
      AppLogger.info('Cache Statistics: $stats', tag: 'CACHE');
    }
  }
}