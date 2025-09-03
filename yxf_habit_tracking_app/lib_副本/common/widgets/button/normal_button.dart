import 'package:flutter/material.dart';

class NormalButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;

  const NormalButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor =
        isOutlined ? Colors.transparent : backgroundColor ?? theme.primaryColor;
    final defaultTextColor = isOutlined
        ? backgroundColor ?? theme.primaryColor
        : textColor ?? Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(borderRadius!),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: defaultBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius!),
            border: isOutlined
                ? Border.all(
                    color: backgroundColor ?? theme.primaryColor,
                    width: 2,
                  )
                : null,
            boxShadow: !isOutlined
                ? [
                    BoxShadow(
                      color: (backgroundColor ?? theme.primaryColor)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(defaultTextColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: defaultTextColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: defaultTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
