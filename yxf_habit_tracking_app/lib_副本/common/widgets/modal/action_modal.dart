import 'package:flutter/material.dart';

/// 底部弹窗动作项模型
class ActionModal {
  /// 动作标签文本
  final String label;
  
  /// 动作图标
  final IconData icon;
  
  /// 点击回调
  final VoidCallback onTap;
  
  /// 图标颜色，默认使用主题色
  final Color? iconColor;
  
  /// 背景颜色，默认使用主题色
  final Color? backgroundColor;
  
  /// 文本颜色，默认使用主题色
  final Color? textColor;
  
  /// 是否为危险操作（红色样式）
  final bool isDestructive;

  const ActionModal({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.textColor,
    this.isDestructive = false,
  });
}

/// 显示底部动作弹窗
/// 
/// [context] 上下文
/// [actions] 动作列表
/// [title] 弹窗标题，可选
/// [backgroundColor] 背景颜色，默认使用主题色
/// [borderRadius] 圆角半径，默认16
/// [enableDrag] 是否允许拖拽，默认true
/// [isDismissible] 是否可点击外部关闭，默认true
void showActionBottomModal({
  required BuildContext context,
  required List<ActionModal> actions,
  String? title,
  Color? backgroundColor,
  double borderRadius = 16,
  bool enableDrag = true,
  bool isDismissible = true,
}) {
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      
      // 计算背景颜色
      final finalBackgroundColor = backgroundColor ?? 
          (isDark ? const Color(0xFF2C2C2E) : Colors.white);
      
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: finalBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 标题区域
            if (title != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withOpacity(0.3),
                    ),
                  ),
                ),
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            
            // 动作列表
            ...actions.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final action = entry.value;
                final isLast = index == actions.length - 1;
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      action.onTap();
                    },
                    borderRadius: BorderRadius.vertical(
                      top: index == 0 && title == null 
                          ? Radius.circular(borderRadius) 
                          : Radius.zero,
                      bottom: isLast 
                          ? Radius.circular(borderRadius) 
                          : Radius.zero,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, 
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: !isLast ? Border(
                          bottom: BorderSide(
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                        ) : null,
                      ),
                      child: Row(
                        children: [
                          // 图标容器
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: action.backgroundColor ?? 
                                  (action.isDestructive 
                                      ? Colors.red.withOpacity(0.1)
                                      : theme.primaryColor.withOpacity(0.1)),
                            ),
                            child: Icon(
                              action.icon,
                              color: action.iconColor ?? 
                                  (action.isDestructive 
                                      ? Colors.red
                                      : theme.primaryColor),
                              size: 20,
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // 标签文本
                          Expanded(
                            child: Text(
                              action.label,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: action.textColor ?? 
                                    (action.isDestructive 
                                        ? Colors.red
                                        : theme.colorScheme.onSurface),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // 底部安全区域
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      );
    },
  );
}

/// 兼容性函数，保持向后兼容
@Deprecated('Use showActionBottomModal instead')
void showTencentCloudChatBottomModal({
  required BuildContext context,
  required List<ActionModal> actions,
}) {
  showActionBottomModal(
    context: context,
    actions: actions,
  );
}
