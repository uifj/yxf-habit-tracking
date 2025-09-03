import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yxf_habit_tracking_app/common/widgets/background/animated_background.dart';
import 'package:intl/intl.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:yxf_habit_tracking_app/core/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../todo/todo_overview/todos_voerview.dart';
import '../../todo/todo_overview/widgets/todo_list_tile.dart';
import '../../todo/edit_todo/edit_todo.dart';

class YxfHomePage extends StatefulWidget {
  const YxfHomePage({super.key});

  @override
  State<YxfHomePage> createState() => _YxfHomePageState();
}

class _YxfHomePageState extends State<YxfHomePage> {
  // 被选中的事件
  late ValueNotifier<List<Todo>> _selectedEvents = ValueNotifier<List<Todo>>(
    [],
  );
  // 用于展示的日历格式(默认是当前这一个星期，可以切换为最近两个星期、当月)
  CalendarFormat _calendarFormat = CalendarFormat.week;
  // 点击两个日期变为选定日期范围
  // RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  // 日历中聚焦的时间(如果是日为单位，就可以具体了某个小时某分某秒了)
  DateTime _focusedDay = DateTime.now();
  // 日历中被选中的时间
  DateTime _selectedDay = DateTime.now();
  // 范围选择时选中的日期起止
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // 初始化或查询时加载待办数据，没加载完就都是加载中
  bool isLoading = false;
  late List<Todo> todoList = [];

  @override
  void initState() {
    super.initState();
    // 获取当前日期的事件
    _queryTodoList(_focusedDay);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // 初始化事件，以当前日查询对应的待办数据
  // 因为不能再改变state中用await，所以单独一个函数
  Future<void> _queryTodoList(DateTime datetime) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // 从TodosRepository获取所有待办数据
      final todosRepository = context.read<TodosRepository>();
      final todosStream = todosRepository.getTodos();

      // 监听stream的第一个值
      final todos = await todosStream.first;

      if (!mounted) return;
      setState(() {
        todoList = todos;
        // 初始化时设定当前选中的日期就是聚焦的日期
        _selectedDay = _focusedDay;
        // 获取当前日期的事件
        _selectedEvents = ValueNotifier(_getTodosForADay(_selectedDay));
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        todoList = [];
        _selectedDay = _focusedDay;
        _selectedEvents = ValueNotifier(_getTodosForADay(_selectedDay));
        isLoading = false;
      });
    }
  }

  List<Todo> _getTodosForADay(DateTime day) {
    // 过滤出指定日期的根级别待办事项（没有parentTodoId的todos）
    final dayTodos = todoList.where((todo) {
      final todoDate = DateTime(
        todo.createdAt.year,
        todo.createdAt.month,
        todo.createdAt.day,
      );
      final targetDate = DateTime(day.year, day.month, day.day);
      return todoDate.isAtSameMomentAs(targetDate) && todo.parentTodoId == null;
    }).toList();

    // 为每个根级别todo构建完整的subtodos树
    return dayTodos.map((todo) => _buildTodoWithSubtodos(todo)).toList();
  }

  // 构建包含完整subtodos树的todo
  Todo _buildTodoWithSubtodos(Todo parentTodo) {
    final subtodos = todoList
        .where((todo) => todo.parentTodoId == parentTodo.id)
        .map((subtodo) => _buildTodoWithSubtodos(subtodo))
        .toList();

    return parentTodo.copyWith(subtodos: subtodos);
  }

  // 当某一天被选中时的回调
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        // 如果当前点击的日期就是已经被选中的日期，日期范围也得情况
        _rangeStart = null;
        _rangeEnd = null;
        // _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
    _selectedEvents.value = _getTodosForADay(selectedDay);
  }

  // 当某个日期被长按可以新增备注？？？
  void _onDayLongPressed(DateTime selectedDay, DateTime focusedDay) {
    debugPrint("日期被长按了---$selectedDay --$focusedDay");
  }

  // 当日期范围被选中时
  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      // _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      // _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // 起止日期可能为null
    if (start != null && end != null) {
      // 有起止，则获取该日期范围内所有的待办数据
      _selectedEvents.value = [
        for (final d in daysInRange(start, end))
          ...(_selectedEvents.value = _getTodosForADay(d)),
      ];
    } else if (start != null) {
      // 只有起，则只获取该起日期的所有待办数据
      _selectedEvents.value = _getTodosForADay(start);
    } else if (end != null) {
      // 只有止，则只获取该止日期的所有待办数据
      _selectedEvents.value = _getTodosForADay(end);
    }
  }

  // 切换待办完成状态
  Future<void> _toggleTodoCompleted(Todo todo, bool isCompleted) async {
    try {
      final todosRepository = context.read<TodosRepository>();
      await todosRepository.saveTodo(todo.copyWith(isCompleted: isCompleted));
      _queryTodoList(_focusedDay);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('更新待办失败')));
      }
    }
  }

  // 删除待办（根据是否有parentTodoId决定删除逻辑）
  Future<void> _deleteTodo(Todo todo) async {
    try {
      final todosRepository = context.read<TodosRepository>();

      if (todo.parentTodoId != null) {
        // 如果是子待办，只删除自己
        await _deleteSubTodo(todo);
      } else {
        // 如果是根待办，删除自己及所有子待办
        await _deleteRootTodoWithSubtodos(todo);
      }

      _queryTodoList(_focusedDay);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除「${todo.title}」'),
            action: SnackBarAction(
              label: '撤销',
              onPressed: () async {
                try {
                  await todosRepository.saveTodo(todo);
                  _queryTodoList(_focusedDay);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('撤销失败')));
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('删除待办失败')));
      }
    }
  }

  // 删除单个子待办
  Future<void> _deleteSubTodo(Todo subtodo) async {
    final todosRepository = context.read<TodosRepository>();
    await todosRepository.deleteTodo(subtodo.id);
  }

  // 删除根待办及其所有子待办
  Future<void> _deleteRootTodoWithSubtodos(Todo rootTodo) async {
    final todosRepository = context.read<TodosRepository>();

    // 递归删除所有子待办
    await _deleteAllSubtodos(rootTodo.id);

    // 删除根待办
    await todosRepository.deleteTodo(rootTodo.id);
  }

  // 递归删除所有子待办
  Future<void> _deleteAllSubtodos(String parentId) async {
    final todosRepository = context.read<TodosRepository>();

    // 找到所有直接子待办
    final directSubtodos = todoList
        .where((todo) => todo.parentTodoId == parentId)
        .toList();

    for (final subtodo in directSubtodos) {
      // 递归删除子待办的子待办
      await _deleteAllSubtodos(subtodo.id);
      // 删除当前子待办
      await todosRepository.deleteTodo(subtodo.id);
    }
  }

  // 切换子待办展开状态
  Future<void> _toggleSubtodosExpanded(Todo todo) async {
    try {
      final todosRepository = context.read<TodosRepository>();
      await todosRepository.saveTodo(
        todo.copyWith(subtodosExpanded: !todo.subtodosExpanded),
      );
      _queryTodoList(_focusedDay);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('更新展开状态失败')));
      }
    }
  }

  // 添加子待办
  void _addSubTodo(Todo parentTodo) {
    Navigator.of(context)
        .push(EditTodoPage.route(parentTodoId: parentTodo.id))
        .then((_) => _queryTodoList(_focusedDay));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('有限风-习惯追踪App'),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Card(child: _buildTodoCalender()),
            Expanded(child: _buildTodoList()),
          ],
        ),
      ),
    );
  }

  TableCalendar<Object?> _buildTodoCalender() {
    return TableCalendar(
      // locale: box.read('language') == 'en' ? "en_US" : 'zh_CN',
      locale: "zh_CN", // 暂时使用中文，"en_US"待定
      firstDay: kFirstDay,
      lastDay: kLastDay,
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      calendarFormat: _calendarFormat,
      // 点击选中日期范围
      // rangeSelectionMode: _rangeSelectionMode,
      // 如果不使用这个函数，当日的数量标记是不会显示的。这也不能是异步函数
      eventLoader: _getTodosForADay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      // 默认的一些日历样式配置，可以自定义日历UI
      calendarStyle: const CalendarStyle(
        // 不是当月的日期不显示
        outsideDaysVisible: false,
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: "月",
        CalendarFormat.twoWeeks: "双周",
        CalendarFormat.week: "周",
      },
      // 自定义修改日历的样式
      calendarBuilders: CalendarBuilders(
        // 这里可以很自定义很多样式，比如单标签多标签等等。
        // 简单示例：当天的待办超过3个，就是黄底黑色；否则就是绿底白字
        markerBuilder: (context, date, list) {
          if (list.isEmpty) return Container();
          return Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 15,
              height: 15,
              color: list.length < 3 ? Colors.green : Colors.yellow,
              child: Center(
                child: Text(
                  "${list.length}",
                  style: TextStyle(
                    color: list.length < 3 ? Colors.white : Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      onDaySelected: _onDaySelected,
      onDayLongPressed: _onDayLongPressed,
      onRangeSelected: _onRangeSelected,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      // 当日历点击标题处的上下页切换后的回调
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        // 当页面切换时，这个聚焦日期为当前页面所在月份的第一天。
        // 页面切换后重新查询当前月的待办数据
        _queryTodoList(focusedDay);
      },
    );
  }

  Widget _buildTodoList() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  '${DateFormat('MM月dd日', 'zh_CN').format(_selectedDay)} 的待办',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // 如果是今日之后的日期，设置createdAt为当天早上7点
                    final now = DateTime.now();
                    final selectedDate = DateTime(
                      _selectedDay.year,
                      _selectedDay.month,
                      _selectedDay.day,
                    );
                    final todayDate = DateTime(now.year, now.month, now.day);

                    DateTime? defaultCreatedAt;
                    if (selectedDate.isAfter(todayDate)) {
                      defaultCreatedAt = DateTime(
                        _selectedDay.year,
                        _selectedDay.month,
                        _selectedDay.day,
                        7,
                        0,
                      );
                    }

                    Navigator.of(context)
                        .push(
                          EditTodoPage.route(
                            defaultCreatedAt: defaultCreatedAt,
                          ),
                        )
                        .then((_) => _queryTodoList(_focusedDay));
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ValueListenableBuilder<List<Todo>>(
              valueListenable: _selectedEvents,
              builder: (context, todos, _) {
                if (isLoading) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                if (todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无待办事项',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击右上角 + 号添加新的待办',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return CupertinoScrollbar(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return TodoListTile(
                        todo: todo,
                        onToggleCompleted: (isCompleted) async {
                          await _toggleTodoCompleted(todo, isCompleted);
                        },
                        onDismissed: (_) async {
                          await _deleteTodo(todo);
                        },
                        onTap: () {
                          _toggleSubtodosExpanded(todo);
                        },
                        onAddSubTodo: () {
                          _addSubTodo(todo);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
