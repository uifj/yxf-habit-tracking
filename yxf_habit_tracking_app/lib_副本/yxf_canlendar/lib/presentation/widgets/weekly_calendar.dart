import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 周历组件
/// 基于priospace-main的设计风格
class WeeklyCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelect;
  final bool darkMode;

  const WeeklyCalendar({
    Key? key,
    required this.selectedDate,
    required this.onDateSelect,
    this.darkMode = false,
  }) : super(key: key);

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late PageController _pageController;
  int _currentWeekIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _pageController = PageController(initialPage: 1000);
    _currentWeekIndex = 1000;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// 格式化月份范围显示
  String _formatMonthRange(DateTime firstDay, DateTime lastDay) {
    try {
      final monthName = DateFormat('MMM', 'zh_CN').format(firstDay);
      return '$monthName ${firstDay.day} - ${lastDay.day}, ${firstDay.year}';
    } catch (e) {
      // 如果本地化数据未初始化，使用基础格式
      try {
        final monthName = DateFormat('MMM').format(firstDay);
        return '$monthName ${firstDay.day} - ${lastDay.day}, ${firstDay.year}';
      } catch (e2) {
        // 最后的降级处理
        return '${firstDay.month}月 ${firstDay.day} - ${lastDay.day}, ${firstDay.year}';
      }
    }
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  List<DateTime> _getWeekDays(int weekOffset) {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now).add(Duration(days: weekOffset * 7));
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: widget.darkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.darkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.darkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildWeekView(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final weekDays = _getWeekDays(_currentWeekIndex - 1000);
    final firstDay = weekDays.first;
    final lastDay = weekDays.last;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.darkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_left,
                size: 20,
                color: widget.darkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Text(
            _formatMonthRange(firstDay, lastDay),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.darkMode ? Colors.white : Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.darkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right,
                size: 20,
                color: widget.darkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentWeekIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final weekDays = _getWeekDays(index - 1000);
        return Row(
          children: weekDays.map((date) => _buildDayItem(date)).toList(),
        );
      },
    );
  }

  Widget _buildDayItem(DateTime date) {
    final isSelected = _isSameDay(date, widget.selectedDate);
    final isToday = _isToday(date);
    final weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
    
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onDateSelect(date),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : isToday
                    ? (widget.darkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isToday && !isSelected
                ? Border.all(
                    color: const Color(0xFF3B82F6),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekdayNames[date.weekday - 1],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (widget.darkMode ? Colors.white70 : Colors.black54),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? const Color(0xFF3B82F6)
                          : (widget.darkMode ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}