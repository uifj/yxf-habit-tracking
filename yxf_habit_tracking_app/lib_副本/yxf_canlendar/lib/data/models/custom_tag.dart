import 'package:equatable/equatable.dart';

/// 自定义标签模型
class CustomTag extends Equatable {
  final int? id;
  final String? userId;
  final String name;
  final String color; // 十六进制颜色值
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive; // 是否激活
  final int usageCount; // 使用次数
  final Map<String, dynamic>? metadata; // 额外数据

  const CustomTag({
    required this.name,
    required this.color,
    required this.createdAt,
    this.id,
    this.userId,
    this.description,
    this.updatedAt,
    this.isActive = true,
    this.usageCount = 0,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        color,
        description,
        createdAt,
        updatedAt,
        isActive,
        usageCount,
        metadata,
      ];

  /// 从JSON创建CustomTag对象
  factory CustomTag.fromJson(Map<String, dynamic> json) {
    return CustomTag(
      id: json['id'],
      userId: json['userId'],
      name: json['name'] ?? '',
      color: json['color'] ?? '#3b82f6',
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isActive: json['isActive'] ?? true,
      usageCount: json['usageCount'] ?? 0,
      metadata: json['metadata'],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'color': color,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'usageCount': usageCount,
      'metadata': metadata,
    };
  }

  /// 创建副本
  CustomTag copyWith({
    int? id,
    String? userId,
    String? name,
    String? color,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? usageCount,
    Map<String, dynamic>? metadata,
  }) {
    return CustomTag(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      usageCount: usageCount ?? this.usageCount,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 工厂方法：创建空标签
  factory CustomTag.empty() {
    return CustomTag(
      name: '',
      color: '#3b82f6',
      createdAt: DateTime.now(),
    );
  }

  /// 预设颜色列表
  static const List<String> presetColors = [
    '#ef4444', // red
    '#f97316', // orange
    '#eab308', // yellow
    '#22c55e', // green
    '#3b82f6', // blue
    '#8b5cf6', // purple
    '#ec4899', // pink
    '#06b6d4', // cyan
    '#a85520', // brown
    '#6366f1', // indigo
    '#64748b', // slate
    '#dc2626', // red-600
    '#ea580c', // orange-600
    '#ca8a04', // yellow-600
    '#16a34a', // green-600
    '#2563eb', // blue-600
    '#7c3aed', // violet-600
    '#db2777', // pink-600
    '#0891b2', // cyan-600
    '#92400e', // amber-700
    '#4f46e5', // indigo-600
  ];

  /// 工厂方法：创建预设标签
  static List<CustomTag> createPresetTags() {
    final now = DateTime.now();
    return [
      CustomTag(
        name: '工作',
        color: '#ef4444',
        description: '工作相关任务',
        createdAt: now,
      ),
      CustomTag(
        name: '学习',
        color: '#3b82f6',
        description: '学习相关任务',
        createdAt: now,
      ),
      CustomTag(
        name: '生活',
        color: '#22c55e',
        description: '日常生活任务',
        createdAt: now,
      ),
      CustomTag(
        name: '健康',
        color: '#f97316',
        description: '健康相关活动',
        createdAt: now,
      ),
      CustomTag(
        name: '娱乐',
        color: '#8b5cf6',
        description: '娱乐休闲活动',
        createdAt: now,
      ),
      CustomTag(
        name: '重要',
        color: '#dc2626',
        description: '重要紧急任务',
        createdAt: now,
      ),
    ];
  }

  /// 获取颜色的整数值
  int get colorValue {
    final hexColor = color.replaceAll('#', '');
    return int.parse('FF$hexColor', radix: 16);
  }

  /// 检查是否为预设颜色
  bool get isPresetColor => presetColors.contains(color);

  /// 增加使用次数
  CustomTag incrementUsage() {
    return copyWith(
      usageCount: usageCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  /// 减少使用次数
  CustomTag decrementUsage() {
    return copyWith(
      usageCount: (usageCount - 1).clamp(0, usageCount),
      updatedAt: DateTime.now(),
    );
  }

  /// 验证标签名称
  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length <= 20;
  }

  /// 验证颜色值
  static bool isValidColor(String color) {
    final hexPattern = RegExp(r'^#[0-9A-Fa-f]{6}$');
    return hexPattern.hasMatch(color);
  }

  /// 获取对比色（用于文字显示）
  String get contrastColor {
    final hexColor = color.replaceAll('#', '');
    final r = int.parse(hexColor.substring(0, 2), radix: 16);
    final g = int.parse(hexColor.substring(2, 4), radix: 16);
    final b = int.parse(hexColor.substring(4, 6), radix: 16);
    
    // 计算亮度
    final brightness = (r * 299 + g * 587 + b * 114) / 1000;
    
    // 根据亮度返回黑色或白色
    return brightness > 128 ? '#000000' : '#FFFFFF';
  }
}