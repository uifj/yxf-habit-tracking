import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../data/models/timer_session.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../bloc/timer_state.dart';

/// 番茄钟计时器模态窗口
/// 基于priospace-main的设计风格
class TimerModal extends StatefulWidget {
  final VoidCallback onClose;

  const TimerModal({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<TimerModal> createState() => _TimerModalState();
}

class _TimerModalState extends State<TimerModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  Timer? _timer;
  int _currentDuration = 25 * 60; // 25分钟默认
  int _remainingTime = 25 * 60;
  bool _isRunning = false;
  bool _isPaused = false;
  String _currentMode = 'work'; // work, shortBreak, longBreak
  int _completedSessions = 0;
  
  final Map<String, int> _durations = {
    'work': 25 * 60,
    'shortBreak': 5 * 60,
    'longBreak': 15 * 60,
  };
  
  final Map<String, String> _modeLabels = {
    'work': '专注时间',
    'shortBreak': '短休息',
    'longBreak': '长休息',
  };
  
  final Map<String, Color> _modeColors = {
    'work': const Color(0xFFEF4444),
    'shortBreak': const Color(0xFF10B981),
    'longBreak': const Color(0xFF3B82F6),
  };
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _resetTimer();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: Duration(seconds: _currentDuration),
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
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: _buildModalContent(),
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
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildModeSelector(),
                  const SizedBox(height: 32),
                  _buildTimerDisplay(),
                  const SizedBox(height: 32),
                  _buildControls(),
                  const SizedBox(height: 24),
                  _buildSessionCounter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _modeColors[_currentMode],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '番茄钟计时器',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: _closeModal,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        _buildModeChip('work'),
        const SizedBox(width: 8),
        _buildModeChip('shortBreak'),
        const SizedBox(width: 8),
        _buildModeChip('longBreak'),
      ],
    );
  }

  Widget _buildModeChip(String mode) {
    final isSelected = _currentMode == mode;
    final color = _modeColors[mode]!;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            _modeLabels[mode]!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? color : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRunning ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 背景圆环
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                  ),
                ),
                // 进度圆环
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(200, 200),
                      painter: CircularProgressPainter(
                        progress: 1.0 - (_remainingTime / _currentDuration),
                        color: _modeColors[_currentMode]!,
                      ),
                    );
                  },
                ),
                // 时间显示
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_remainingTime),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _modeColors[_currentMode],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _modeLabels[_currentMode]!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 重置按钮
        GestureDetector(
          onTap: _resetTimer,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(
              Icons.refresh,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // 播放/暂停按钮
        GestureDetector(
          onTap: _toggleTimer,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _modeColors[_currentMode],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _modeColors[_currentMode]!.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // 跳过按钮
        GestureDetector(
          onTap: _skipTimer,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(
              Icons.skip_next,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCounter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: _modeColors[_currentMode],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '已完成 $_completedSessions 个番茄钟',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _switchMode(String mode) {
    if (_isRunning) return;
    
    setState(() {
      _currentMode = mode;
      _currentDuration = _durations[mode]!;
      _remainingTime = _currentDuration;
    });
    
    _progressController.duration = Duration(seconds: _currentDuration);
    _progressController.reset();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    
    _pulseController.repeat(reverse: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _completeSession();
        }
      });
    });
    
    // 启动进度动画
    if (!_progressController.isAnimating) {
      _progressController.forward();
    }
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
    
    _timer?.cancel();
    _pulseController.stop();
    _progressController.stop();
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _progressController.reset();
    
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingTime = _currentDuration;
    });
  }

  void _skipTimer() {
    _completeSession();
  }

  void _completeSession() {
    _timer?.cancel();
    _pulseController.stop();
    _progressController.reset();
    
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
    
    // 记录完成的会话
    if (_currentMode == 'work') {
      setState(() {
        _completedSessions++;
      });
      
      // 保存计时会话到BLoC
      final now = DateTime.now();
      final session = TimerSession(
        type: SessionType.work,
        status: SessionStatus.completed,
        durationMinutes: _currentDuration ~/ 60,
        startTime: now.subtract(Duration(seconds: _currentDuration)),
        createdAt: now,
        isCompleted: true,
      );
      
      context.read<TimerBloc>().add(StartTimerEvent(sessionType: SessionType.work));
      
      // 自动切换到休息模式
      if (_completedSessions % 4 == 0) {
        _switchMode('longBreak');
      } else {
        _switchMode('shortBreak');
      }
    } else {
      // 休息结束，切换到工作模式
      _switchMode('work');
    }
    
    // 显示完成提示
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.celebration,
              color: _modeColors[_currentMode],
            ),
            const SizedBox(width: 8),
            const Text('完成！'),
          ],
        ),
        content: Text(
          _currentMode == 'work'
              ? '恭喜完成一个番茄钟！是时候休息一下了。'
              : '休息结束！准备开始下一个番茄钟吧。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }

  void _closeModal() {
    _timer?.cancel();
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

/// 自定义圆形进度条画笔
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  CircularProgressPainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}