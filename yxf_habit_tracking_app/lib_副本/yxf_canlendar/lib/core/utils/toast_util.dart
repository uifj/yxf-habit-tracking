import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Toast提示类型枚举
enum ToastType {
  success,
  error,
  warning,
  info,
  loading,
}

/// Toast位置枚举
enum ToastPosition {
  top,
  center,
  bottom,
}

/// Toast配置类
class ToastConfig {
  final Duration duration;
  final ToastPosition position;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool enableHapticFeedback;
  final bool dismissOnTap;
  final double? maxWidth;
  final TextAlign textAlign;

  const ToastConfig({
    this.duration = const Duration(seconds: 2),
    this.position = ToastPosition.center,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.enableHapticFeedback = true,
    this.dismissOnTap = true,
    this.maxWidth,
    this.textAlign = TextAlign.center,
  });
}

/// 企业级Toast工具类
/// 参考后台管理平台和微信的提示方式设计
class ToastUtil {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// 默认配置
  static const ToastConfig _defaultConfig = ToastConfig();

  /// 显示成功提示
  /// [message] 提示消息
  /// [config] 自定义配置
  static void success(
    String message, {
    ToastConfig? config,
  }) {
    _showToast(
      message,
      ToastType.success,
      config ?? _defaultConfig,
    );
  }

  /// 显示错误提示
  /// [message] 错误消息
  /// [config] 自定义配置
  static void error(
    String message, {
    ToastConfig? config,
  }) {
    _showToast(
      message,
      ToastType.error,
      config ?? _defaultConfig,
    );
  }

  /// 显示警告提示
  /// [message] 警告消息
  /// [config] 自定义配置
  static void warning(
    String message, {
    ToastConfig? config,
  }) {
    _showToast(
      message,
      ToastType.warning,
      config ?? _defaultConfig,
    );
  }

  /// 显示信息提示
  /// [message] 信息消息
  /// [config] 自定义配置
  static void info(
    String message, {
    ToastConfig? config,
  }) {
    _showToast(
      message,
      ToastType.info,
      config ?? _defaultConfig,
    );
  }

  /// 显示加载提示
  /// [message] 加载消息
  /// [config] 自定义配置
  static void loading(
    String message, {
    ToastConfig? config,
  }) {
    _showToast(
      message,
      ToastType.loading,
      config ??
          const ToastConfig(
            duration: Duration(seconds: 30), // 加载提示默认较长时间
            dismissOnTap: false, // 加载提示不允许点击关闭
          ),
    );
  }

  /// 隐藏当前显示的Toast
  static void hide() {
    if (_isShowing && _overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  /// 显示Toast的核心方法
  static void _showToast(
    String message,
    ToastType type,
    ToastConfig config,
  ) {
    // 如果已有Toast在显示，先隐藏
    hide();

    // 获取当前上下文
    final context = _getContext();
    if (context == null) return;

    // 触觉反馈
    if (config.enableHapticFeedback) {
      _triggerHapticFeedback(type);
    }

    // 创建OverlayEntry
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        config: config,
        onDismiss: hide,
      ),
    );

    // 显示Toast
    Overlay.of(context).insert(_overlayEntry!);
    _isShowing = true;

    // 自动隐藏
    if (type != ToastType.loading) {
      Future.delayed(config.duration, () {
        hide();
      });
    }
  }

  /// 获取当前上下文
  static BuildContext? _getContext() {
    return _navigatorKey?.currentContext;
  }

  /// 全局导航键，需要在MaterialApp中设置
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// 初始化ToastUtil
  /// [navigatorKey] 全局导航键
  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// 触发触觉反馈
  static void _triggerHapticFeedback(ToastType type) {
    switch (type) {
      case ToastType.success:
        HapticFeedback.lightImpact();
        break;
      case ToastType.error:
        HapticFeedback.heavyImpact();
        break;
      case ToastType.warning:
        HapticFeedback.mediumImpact();
        break;
      case ToastType.info:
      case ToastType.loading:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// 获取Toast类型对应的颜色
  static Color _getTypeColor(ToastType type, {bool isBackground = false}) {
    switch (type) {
      case ToastType.success:
        return isBackground
            ? const Color(0xFF52C41A).withOpacity(0.9)
            : Colors.white;
      case ToastType.error:
        return isBackground
            ? const Color(0xFFFF4D4F).withOpacity(0.9)
            : Colors.white;
      case ToastType.warning:
        return isBackground
            ? const Color(0xFFFAAD14).withOpacity(0.9)
            : Colors.white;
      case ToastType.info:
        return isBackground
            ? const Color(0xFF1890FF).withOpacity(0.9)
            : Colors.white;
      case ToastType.loading:
        return isBackground
            ? const Color(0xFF595959).withOpacity(0.9)
            : Colors.white;
    }
  }

  /// 获取Toast类型对应的图标
  static IconData _getTypeIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
      case ToastType.loading:
        return Icons.hourglass_empty;
    }
  }
}

/// Toast组件
class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final ToastConfig config;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.config,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _animationController.forward();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // 根据位置设置滑动动画
    Offset beginOffset;
    switch (widget.config.position) {
      case ToastPosition.top:
        beginOffset = const Offset(0, -1);
        break;
      case ToastPosition.center:
        beginOffset = const Offset(0, 0);
        break;
      case ToastPosition.bottom:
        beginOffset = const Offset(0, 1);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: widget.config.dismissOnTap ? widget.onDismiss : null,
          child: Container(
            alignment: _getAlignment(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 50,
            ),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildToastContent(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 获取对齐方式
  Alignment _getAlignment() {
    switch (widget.config.position) {
      case ToastPosition.top:
        return Alignment.topCenter;
      case ToastPosition.center:
        return Alignment.center;
      case ToastPosition.bottom:
        return Alignment.bottomCenter;
    }
  }

  /// 构建Toast内容
  Widget _buildToastContent() {
    final backgroundColor = widget.config.backgroundColor ??
        ToastUtil._getTypeColor(widget.type, isBackground: true);
    final textColor = widget.config.textColor ??
        ToastUtil._getTypeColor(widget.type, isBackground: false);

    return Container(
      constraints: BoxConstraints(
        maxWidth: widget.config.maxWidth ?? 280,
        minHeight: 48,
      ),
      padding: widget.config.padding ??
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: widget.config.borderRadius ?? BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.type == ToastType.loading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          else
            Icon(
              ToastUtil._getTypeIcon(widget.type),
              color: textColor,
              size: 16,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.message,
              style: TextStyle(
                color: textColor,
                fontSize: widget.config.fontSize ?? 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: widget.config.textAlign,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Toast扩展方法
extension ToastExtension on String {
  /// 显示成功提示
  void showSuccess([ToastConfig? config]) {
    ToastUtil.success(this, config: config);
  }

  /// 显示错误提示
  void showError([ToastConfig? config]) {
    ToastUtil.error(this, config: config);
  }

  /// 显示警告提示
  void showWarning([ToastConfig? config]) {
    ToastUtil.warning(this, config: config);
  }

  /// 显示信息提示
  void showInfo([ToastConfig? config]) {
    ToastUtil.info(this, config: config);
  }

  /// 显示加载提示
  void showLoading([ToastConfig? config]) {
    ToastUtil.loading(this, config: config);
  }
}
