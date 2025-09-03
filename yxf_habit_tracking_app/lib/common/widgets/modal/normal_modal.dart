import 'package:flutter/material.dart';

/// 通用模态窗口基础组件
/// 提供统一的动画、布局和交互逻辑
class NormalModal extends StatefulWidget {
  /// 模态窗口标题
  final String title;
  
  /// 标题图标
  final IconData? titleIcon;
  
  /// 主题色
  final Color primaryColor;
  
  /// 模态窗口内容
  final Widget content;
  
  /// 关闭回调
  final VoidCallback onClose;
  
  /// 最大宽度
  final double? maxWidth;
  
  /// 最大高度
  final double? maxHeight;
  
  /// 是否显示返回按钮
  final bool showBackButton;
  
  /// 返回按钮回调
  final VoidCallback? onBack;
  
  /// 是否显示关闭按钮
  final bool showCloseButton;
  
  /// 自定义头部操作按钮
  final List<Widget>? headerActions;
  
  /// 是否启用背景点击关闭
  final bool dismissible;
  
  const NormalModal({
    Key? key,
    required this.title,
    this.titleIcon,
    this.primaryColor = const Color(0xFF6366F1),
    required this.content,
    required this.onClose,
    this.maxWidth = 500,
    this.maxHeight = 700,
    this.showBackButton = false,
    this.onBack,
    this.showCloseButton = true,
    this.headerActions,
    this.dismissible = true,
  }) : super(key: key);

  @override
  State<NormalModal> createState() => _NormalModalState();
}

class _NormalModalState extends State<NormalModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.dismissible ? _closeModal : null,
          child: Container(
            color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
            child: Center(
              child: GestureDetector(
                onTap: () {}, // 阻止事件冒泡
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildModalContent(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalContent() {
    return Container(
      margin: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth ?? 500,
        maxHeight: widget.maxHeight ?? 700,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: widget.content,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          if (widget.titleIcon != null) ...[
            Icon(
              widget.titleIcon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // 自定义头部操作按钮
          if (widget.headerActions != null) ...
            widget.headerActions!.map((action) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: action,
            )),
          // 返回按钮
          if (widget.showBackButton) ...[
            const SizedBox(width: 8),
            _buildHeaderButton(
              icon: Icons.arrow_back,
              onTap: widget.onBack ?? () {},
            ),
          ],
          // 关闭按钮
          if (widget.showCloseButton) ...[
            const SizedBox(width: 8),
            _buildHeaderButton(
              icon: Icons.close,
              onTap: _closeModal,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }
}

/// 模态窗口内容包装器
/// 提供统一的内边距和滚动支持
class ModalContentWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  const ModalContentWrapper({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.scrollable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );

    if (scrollable) {
      content = SingleChildScrollView(
        child: content,
      );
    }

    return content;
  }
}

/// 模态窗口底部操作栏
class ModalActionBar extends StatelessWidget {
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment alignment;

  const ModalActionBar({
    Key? key,
    required this.actions,
    this.padding = const EdgeInsets.all(24),
    this.alignment = MainAxisAlignment.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: alignment,
        children: _buildActionsWithSpacing(),
      ),
    );
  }

  List<Widget> _buildActionsWithSpacing() {
    final List<Widget> spacedActions = [];
    for (int i = 0; i < actions.length; i++) {
      spacedActions.add(actions[i]);
      if (i < actions.length - 1) {
        spacedActions.add(const SizedBox(width: 16));
      }
    }
    return spacedActions;
  }
}

/// 通用模态按钮样式
class ModalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final bool isExpanded;
  final IconData? icon;

  const ModalButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.isExpanded = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button;

    if (isOutlined) {
      button = TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: backgroundColor ?? Colors.grey,
            ),
          ),
        ),
        child: _buildButtonContent(),
      );
    } else {
      button = ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF6366F1),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _buildButtonContent(),
      );
    }

    if (isExpanded) {
      button = Expanded(child: button);
    }

    return button;
  }

  Widget _buildButtonContent() {
    final List<Widget> children = [];

    if (icon != null) {
      children.add(Icon(
        icon,
        size: 20,
        color: isOutlined
            ? (textColor ?? Colors.black54)
            : (textColor ?? Colors.white),
      ));
      children.add(const SizedBox(width: 8));
    }

    children.add(Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isOutlined
            ? (textColor ?? Colors.black54)
            : (textColor ?? Colors.white),
      ),
    ));

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}