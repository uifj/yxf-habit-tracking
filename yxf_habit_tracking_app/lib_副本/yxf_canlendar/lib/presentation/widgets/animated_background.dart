import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 动画背景组件
/// 基于priospace-main的设计风格，提供动态背景效果
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool isDarkMode;

  const AnimatedBackground({
    Key? key,
    required this.child,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // 第一个动画控制器 - 慢速旋转
    _controller1 = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _animation1 = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller1,
      curve: Curves.linear,
    ));

    // 第二个动画控制器 - 中速旋转
    _controller2 = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    _animation2 = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller2,
      curve: Curves.linear,
    ));

    // 第三个动画控制器 - 快速旋转
    _controller3 = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );
    _animation3 = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller3,
      curve: Curves.linear,
    ));

    // 开始动画
    _controller1.repeat();
    _controller2.repeat();
    _controller3.repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景渐变
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDarkMode
                  ? [
                      const Color(0xFF1a1a2e),
                      const Color(0xFF16213e),
                      const Color(0xFF0f3460),
                    ]
                  : [
                      const Color(0xFFf8fafc),
                      const Color(0xFFe2e8f0),
                      const Color(0xFFcbd5e1),
                    ],
            ),
          ),
        ),
        // 动画圆形1
        AnimatedBuilder(
          animation: _animation1,
          builder: (context, child) {
            return Positioned(
              top: -100 + math.sin(_animation1.value) * 50,
              right: -100 + math.cos(_animation1.value) * 30,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: widget.isDarkMode
                        ? [
                            const Color(0xFF6366F1).withOpacity(0.1),
                            const Color(0xFF6366F1).withOpacity(0.05),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFF6366F1).withOpacity(0.15),
                            const Color(0xFF6366F1).withOpacity(0.08),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            );
          },
        ),
        // 动画圆形2
        AnimatedBuilder(
          animation: _animation2,
          builder: (context, child) {
            return Positioned(
              bottom: -150 + math.cos(_animation2.value) * 40,
              left: -150 + math.sin(_animation2.value) * 60,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: widget.isDarkMode
                        ? [
                            const Color(0xFF8B5CF6).withOpacity(0.08),
                            const Color(0xFF8B5CF6).withOpacity(0.04),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFF8B5CF6).withOpacity(0.12),
                            const Color(0xFF8B5CF6).withOpacity(0.06),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            );
          },
        ),
        // 动画圆形3
        AnimatedBuilder(
          animation: _animation3,
          builder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).size.height * 0.3 +
                  math.sin(_animation3.value) * 30,
              right: -200 + math.cos(_animation3.value) * 50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: widget.isDarkMode
                        ? [
                            const Color(0xFF06B6D4).withOpacity(0.1),
                            const Color(0xFF06B6D4).withOpacity(0.05),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFF06B6D4).withOpacity(0.15),
                            const Color(0xFF06B6D4).withOpacity(0.08),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            );
          },
        ),
        // 浮动粒子效果
        ...List.generate(8, (index) {
          return AnimatedBuilder(
            animation: _controller1,
            builder: (context, child) {
              final double offset = (index * math.pi / 4) + _animation1.value;
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.2 +
                    math.sin(offset) * 100,
                left: MediaQuery.of(context).size.width * 0.1 +
                    math.cos(offset) * 150 +
                    (index * 50),
                child: Container(
                  width: 4 + (index % 3) * 2,
                  height: 4 + (index % 3) * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFF6366F1).withOpacity(0.2),
                  ),
                ),
              );
            },
          );
        }),
        // 网格背景效果
        CustomPaint(
          size: Size.infinite,
          painter: GridPainter(
            isDarkMode: widget.isDarkMode,
            animation: _animation1,
          ),
        ),
        // 子组件
        widget.child,
      ],
    );
  }
}

/// 网格背景绘制器
class GridPainter extends CustomPainter {
  final bool isDarkMode;
  final Animation<double> animation;

  GridPainter({
    required this.isDarkMode,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode
          ? Colors.white.withOpacity(0.02)
          : const Color(0xFF6366F1).withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double gridSize = 50;
    final double animationOffset = animation.value * gridSize;

    // 绘制垂直线
    for (double x = -gridSize + (animationOffset % gridSize);
        x < size.width + gridSize;
        x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 绘制水平线
    for (double y = -gridSize + (animationOffset % gridSize);
        y < size.height + gridSize;
        y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// 简化版动画背景（性能优化版本）
class SimpleAnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool isDarkMode;

  const SimpleAnimatedBackground({
    Key? key,
    required this.child,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  State<SimpleAnimatedBackground> createState() =>
      _SimpleAnimatedBackgroundState();
}

class _SimpleAnimatedBackgroundState extends State<SimpleAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 简单渐变背景
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDarkMode
                  ? [
                      const Color(0xFF1a1a2e),
                      const Color(0xFF16213e),
                    ]
                  : [
                      const Color(0xFFf8fafc),
                      const Color(0xFFe2e8f0),
                    ],
            ),
          ),
        ),
        // 单个动画圆形
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Positioned(
              top: -100 + math.sin(_animation.value * 2 * math.pi) * 30,
              right: -100 + math.cos(_animation.value * 2 * math.pi) * 20,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // 子组件
        widget.child,
      ],
    );
  }
}