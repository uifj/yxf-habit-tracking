import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yxf_habit_tracking_app/app/l10n/l10n.dart';
import 'package:yxf_habit_tracking_app/common/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:yxf_habit_tracking_app/core/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../todos_voerview.dart';
import '../widgets/todo_list_tile.dart';
import '../../edit_todo/edit_todo.dart';

import 'package:yxf_habit_tracking_app/app/theme/theme.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
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
  // 被选中的事件
  late final ValueNotifier<List<Todo>> _selectedEvents =
      ValueNotifier<List<Todo>>([]);
  // 所有待办事件
  late List<Todo> todoList = [];

  // 无限滚动相关
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;
  int _currentPage = 0;
  static const int _pageSize = 20; // 每页加载的待办数量

  @override
  void initState() {
    super.initState();
    // 添加滚动监听
    _scrollController.addListener(_onScroll);
    // 获取当前日期的事件
    _queryTodoList(_focusedDay);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        // 重置分页状态并加载第一页数据
        _currentPage = 0;
        _hasReachedMax = false;
        isLoading = false;
      });
      // 加载第一页待办数据
      _loadTodosForDay(_selectedDay, reset: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        todoList = [];
        _selectedDay = _focusedDay;
        _currentPage = 0;
        _hasReachedMax = false;
        isLoading = false;
      });
      // 加载空数据
      _selectedEvents.value = [];
    }
  }

  List<Todo> _getTodosForADay(DateTime day, {int? limit, int? offset}) {
    // 过滤出指定日期的根级别待办事项（没有parentTodoId的todos）
    var dayTodos = todoList.where((todo) {
      final todoDate = DateTime(
        todo.createdAt.year,
        todo.createdAt.month,
        todo.createdAt.day,
      );
      final targetDate = DateTime(day.year, day.month, day.day);
      return todoDate.isAtSameMomentAs(targetDate) && todo.parentTodoId == null;
    }).toList();

    // 按创建时间排序（最新的在前）
    dayTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 分页处理
    if (limit != null && offset != null) {
      final startIndex = offset;
      final endIndex = (startIndex + limit).clamp(0, dayTodos.length);
      if (startIndex >= dayTodos.length) {
        return [];
      }
      dayTodos = dayTodos.sublist(startIndex, endIndex);
    }

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
        // 重置分页状态
        _currentPage = 0;
        _hasReachedMax = false;
      });
    }
    // 重新加载第一页数据
    _loadTodosForDay(selectedDay, reset: true);
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
      // 重置分页状态
      _currentPage = 0;
      _hasReachedMax = false;
    });

    // 起止日期可能为null
    if (start != null && end != null) {
      // 有起止，则获取该日期范围内所有的待办数据（暂时不支持范围分页）
      _selectedEvents.value = [
        for (final d in daysInRange(start, end)) ..._getTodosForADay(d),
      ];
      _hasReachedMax = true; // 范围选择时禁用分页
    } else if (start != null) {
      // 只有起，则只获取该起日期的所有待办数据
      _loadTodosForDay(start, reset: true);
    } else if (end != null) {
      // 只有止，则只获取该止日期的所有待办数据
      _loadTodosForDay(end, reset: true);
    }
  }

  // ========== 无限滚动相关方法 ==========

  /// 滚动监听器
  void _onScroll() {
    if (_isBottom && !_isLoadingMore && !_hasReachedMax) {
      _loadMoreTodos();
    }
  }

  /// 检查是否滚动到底部
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  /// 加载指定日期的待办数据
  void _loadTodosForDay(DateTime day, {bool reset = false}) {
    if (reset) {
      _currentPage = 0;
      _hasReachedMax = false;
      _selectedEvents.value = [];
    }

    final todos = _getTodosForADay(
      day,
      limit: _pageSize,
      offset: _currentPage * _pageSize,
    );

    if (reset) {
      _selectedEvents.value = todos;
    } else {
      _selectedEvents.value = [..._selectedEvents.value, ...todos];
    }

    // 检查是否已达到最大值
    if (todos.length < _pageSize) {
      _hasReachedMax = true;
    }

    if (!reset) {
      _currentPage++;
    }
  }

  /// 加载更多待办数据
  Future<void> _loadMoreTodos() async {
    if (_isLoadingMore || _hasReachedMax) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));

      _currentPage++;
      final moreTodos = _getTodosForADay(
        _selectedDay,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      if (moreTodos.isEmpty || moreTodos.length < _pageSize) {
        _hasReachedMax = true;
      }

      if (moreTodos.isNotEmpty) {
        _selectedEvents.value = [..._selectedEvents.value, ...moreTodos];
      }
    } catch (e) {
      debugPrint('加载更多待办失败: $e');
      _currentPage--; // 回滚页码
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  /// 构建底部加载指示器
  Widget _buildBottomLoader() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      child: _isLoadingMore
          ? const CupertinoActivityIndicator()
          : _hasReachedMax
              ? Text(
                  '已加载全部待办',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                )
              : const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnimatedBackground(
      isDarkMode: context.read<ThemeCubit>().state.themeMode == ThemeMode.dark,
      child: BlocProvider(
        create: (context) =>
            TodosOverviewBloc(todosRepository: context.read<TodosRepository>())
              ..add(const TodosOverviewSubscriptionRequested()),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: false,
            title: const Text('有限风-习惯追踪App'),
            backgroundColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OpacityButton(icon: Icons.alarm_rounded, onTap: () {}),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OpacityButton(
                  icon: Icons.list_alt_outlined,
                  onTap: () {},
                ),
              ),
            ],
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<TodosOverviewBloc, TodosOverviewState>(
                listenWhen: (previous, current) =>
                    previous.status != current.status,
                listener: (context, state) {
                  if (state.status == TodosOverviewStatus.failure) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(l10n.todosOverviewErrorSnackbarText),
                        ),
                      );
                  }
                },
              ),
              // 监听todos数据变化，自动同步本地状态
              BlocListener<TodosOverviewBloc, TodosOverviewState>(
                listenWhen: (previous, current) =>
                    previous.todos != current.todos,
                listener: (context, state) {
                  if (mounted) {
                    setState(() {
                      todoList = state.todos;
                    });
                    // 重新加载当前选中日期的待办数据
                    _loadTodosForDay(_selectedDay, reset: true);
                  }
                },
              ),
              BlocListener<TodosOverviewBloc, TodosOverviewState>(
                listenWhen: (previous, current) =>
                    previous.lastDeletedTodo != current.lastDeletedTodo &&
                    current.lastDeletedTodo != null,
                listener: (context, state) {
                  final deletedTodo = state.lastDeletedTodo!;
                  final messenger = ScaffoldMessenger.of(context);
                  messenger
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.todosOverviewTodoDeletedSnackbarText(
                            deletedTodo.title,
                          ),
                        ),
                        action: SnackBarAction(
                          label: l10n.todosOverviewUndoDeletionButtonText,
                          onPressed: () {
                            messenger.hideCurrentSnackBar();
                            context.read<TodosOverviewBloc>().add(
                                  const TodosOverviewUndoDeletionRequested(),
                                );
                          },
                        ),
                      ),
                    );
                },
              ),
            ],
            child: Column(
              children: [
                Card(child: _buildTodoCalender()),
                Expanded(child: _buildTodoList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableCalendar<Object?> _buildTodoCalender() {
    return TableCalendar(
      // locale: box.read('language') == 'en' ? "en_US" : 'zh_CN',
      locale: context.isEnglish ? 'en_US' : 'zh_CN', // 暂时使用中文，"en_US"待定
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
        CalendarFormat.month: "展示月",
        // CalendarFormat.twoWeeks: "双周",
        CalendarFormat.week: "展示周",
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击右上角 + 号添加新的待办',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return CupertinoScrollbar(
                  controller: _scrollController,
                  child: BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
                    builder: (context, state) {
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        itemCount:
                            _hasReachedMax ? todos.length : todos.length + 1,
                        itemBuilder: (context, index) {
                          // 如果是最后一项且未达到最大值，显示加载指示器
                          if (index >= todos.length) {
                            return _buildBottomLoader();
                          }

                          final todo = todos[index];
                          return TodoListTile(
                            todo: todo,
                            onToggleCompleted: (isCompleted) {
                              context.read<TodosOverviewBloc>().add(
                                    TodosOverviewTodoCompletionToggled(
                                      todo: todo,
                                      isCompleted: isCompleted,
                                    ),
                                  );
                            },
                            onDismissed: (_) {
                              context.read<TodosOverviewBloc>().add(
                                    TodosOverviewTodoDeleted(todo),
                                  );
                              // // 找到所有直接子待办
                              // final directSubtodos = todoList
                              //     .where((todo) => todo.parentTodoId == todo.id)
                              //     .toList();

                              // for (final subtodo in directSubtodos) {
                              //   // 递归删除当前子待办
                              //   context
                              //       .read<TodosOverviewBloc>()
                              //       .add(TodosOverviewTodoDeleted(subtodo));
                              // }
                            },
                            onTap: () {
                              context.read<TodosOverviewBloc>().add(
                                    TodosOverviewSubtodoExpansionToggled(
                                      todo,
                                    ),
                                  );
                            },
                            onLongPress: () {
                              Navigator.of(context)
                                  .push(EditTodoPage.route(initialTodo: todo))
                                  .then((_) => _queryTodoList(_focusedDay));
                            },
                            onAddSubTodo: () {
                              Navigator.of(context).push(
                                  EditTodoPage.route(parentTodoId: todo.id));
                            },
                            // 子待办专用回调方法
                            onSubtodoToggleCompleted: (subtodo) {
                              context.read<TodosOverviewBloc>().add(
                                    TodosOverviewTodoCompletionToggled(
                                      todo: subtodo,
                                      isCompleted: subtodo.isCompleted,
                                    ),
                                  );
                            },
                            onSubtodoDismissed: (subtodo) async {
                              context.read<TodosOverviewBloc>().add(
                                    TodosOverviewTodoDeleted(subtodo),
                                  );
                            },
                            onSubtodoTap: (subtodo) {
                              context.read<TodosOverviewBloc>().add(
                                    TodosOverviewSubtodoExpansionToggled(
                                      subtodo,
                                    ),
                                  );
                            },
                            onSubtodoLongPress: (subtodo) {
                              Navigator.of(context)
                                  .push(
                                    EditTodoPage.route(initialTodo: subtodo),
                                  )
                                  .then((_) => _queryTodoList(_focusedDay));
                            },
                          );
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
