import 'package:flutter/material.dart';

/// 透明背景按钮组件
/// 
/// 一个具有透明背景和边框的圆角按钮，支持深色和浅色主题
class OpacityButton extends StatelessWidget {
  /// 按钮图标
  final IconData icon;
  
  /// 点击回调
  final VoidCallback onTap;
  
  /// 按钮尺寸，默认44x44
  final double size;
  
  /// 图标尺寸，默认20
  final double iconSize;
  
  /// 圆角半径，默认12
  final double borderRadius;
  
  /// 是否启用，默认true
  final bool enabled;
  
  /// 自定义背景色透明度，默认null（使用主题色）
  final double? backgroundOpacity;
  
  /// 自定义边框色透明度，默认null（使用主题色）
  final double? borderOpacity;
  
  /// 自定义图标颜色，默认null（使用主题色）
  final Color? iconColor;

  const OpacityButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 20,
    this.borderRadius = 12,
    this.enabled = true,
    this.backgroundOpacity,
    this.borderOpacity,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 计算颜色
    final backgroundColor = isDark
        ? Colors.white.withOpacity(backgroundOpacity ?? 0.1)
        : Colors.black.withOpacity(backgroundOpacity ?? 0.05);
        
    final borderColor = isDark
        ? Colors.white.withOpacity(borderOpacity ?? 0.2)
        : Colors.black.withOpacity(borderOpacity ?? 0.1);
        
    final finalIconColor = iconColor ?? 
        (isDark ? Colors.white : Colors.black87);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: enabled ? backgroundColor : backgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: enabled ? borderColor : borderColor.withOpacity(0.5),
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: enabled ? finalIconColor : finalIconColor.withOpacity(0.5),
        ),
      ),
    );
  }
}

/// 便捷函数，用于快速创建透明背景按钮
Widget opacityButton({
  required IconData icon,
  required VoidCallback onTap,
  double size = 44,
  double iconSize = 20,
  double borderRadius = 12,
  bool enabled = true,
  double? backgroundOpacity,
  double? borderOpacity,
  Color? iconColor,
}) {
  return OpacityButton(
    icon: icon,
    onTap: onTap,
    size: size,
    iconSize: iconSize,
    borderRadius: borderRadius,
    enabled: enabled,
    backgroundOpacity: backgroundOpacity,
    borderOpacity: borderOpacity,
    iconColor: iconColor,
  );
}
