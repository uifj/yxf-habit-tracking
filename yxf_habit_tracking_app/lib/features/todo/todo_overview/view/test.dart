import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../edit_todo/edit_todo.dart';
import '../todos_voerview.dart';
import 'package:todos_repository/todos_repository.dart';

class TodosOverviewPage extends StatefulWidget {
  const TodosOverviewPage({super.key});

  @override
  State<TodosOverviewPage> createState() => _TodosOverviewPageState();
}

class _TodosOverviewPageState extends State<TodosOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodosOverviewBloc(
        todosRepository: context.read<TodosRepository>(),
      )..add(const TodosOverviewSubscriptionRequested()),
      child: const TodosOverviewView(),
    );
  }
}

class TodosOverviewView extends StatefulWidget {
  const TodosOverviewView({super.key});

  @override
  State<TodosOverviewView> createState() => _TodosOverviewViewState();
}

class _TodosOverviewViewState extends State<TodosOverviewView> {
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 分页状态
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;
  int _currentPage = 0;
  static const int _pageSize = 20;

  // 按日期分组的待办数据
  final Map<String, List<Todo>> _groupedTodos = {};
  List<String> _dateKeys = [];

  // 上一次的过滤状态，用于检测过滤条件变化
  TodosViewFilter? _lastFilter;
  int _lastTodosCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

  /// 加载更多待办数据
  Future<void> _loadMoreTodos() async {
    if (_isLoadingMore || _hasReachedMax) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));

      // 这里应该调用实际的分页API，暂时使用现有数据模拟
      final bloc = context.read<TodosOverviewBloc>();
      final allTodos = bloc.state.filteredTodos.toList();

      final nextPage = _currentPage + 1;
      final startIndex = nextPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(0, allTodos.length);

      if (startIndex >= allTodos.length) {
        setState(() {
          _hasReachedMax = true;
          _isLoadingMore = false;
        });
        return;
      }

      final newTodos = allTodos.sublist(startIndex, endIndex);
      _addTodosToGroups(newTodos);

      setState(() {
        _currentPage = nextPage;
        _hasReachedMax = endIndex >= allTodos.length;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// 将待办数据按日期分组
  void _groupTodosByDate(List<Todo> todos) {
    _groupedTodos.clear();
    _dateKeys.clear();

    for (final todo in todos) {
      final dateKey = _formatDateKey(todo.createdAt);
      if (!_groupedTodos.containsKey(dateKey)) {
        _groupedTodos[dateKey] = [];
      }
      _groupedTodos[dateKey]!.add(todo);
    }

    _dateKeys = _groupedTodos.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 按日期倒序排列
  }

  /// 添加新的待办数据到分组中
  void _addTodosToGroups(List<Todo> newTodos) {
    for (final todo in newTodos) {
      final dateKey = _formatDateKey(todo.createdAt);
      if (!_groupedTodos.containsKey(dateKey)) {
        _groupedTodos[dateKey] = [];
        _dateKeys.add(dateKey);
      }
      _groupedTodos[dateKey]!.add(todo);
    }

    _dateKeys.sort((a, b) => b.compareTo(a)); // 重新排序
  }

  /// 格式化日期键
  String _formatDateKey(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  /// 检测过滤条件或数据是否发生变化
  bool _shouldResetData(TodosOverviewState state) {
    return _lastFilter != state.filter ||
        _lastTodosCount != state.todos.length ||
        (_groupedTodos.isEmpty && state.filteredTodos.isNotEmpty);
  }

  /// 初始化或重置分组数据
  void _initializeGroupedData(TodosOverviewState state) {
    if (_shouldResetData(state)) {
      final initialTodos = state.filteredTodos.take(_pageSize).toList();
      _groupTodosByDate(initialTodos);
      _currentPage = 0;
      _hasReachedMax = initialTodos.length < _pageSize ||
          initialTodos.length >= state.filteredTodos.length;

      // 更新状态追踪
      _lastFilter = state.filter;
      _lastTodosCount = state.todos.length;
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                )
              : const SizedBox.shrink(),
    );
  }

  /// 构建日期分隔符
  Widget _buildDateSeparator(String dateKey) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '-------$dateKey--------',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  /// 构建按日期分组的待办列表
  Widget _buildGroupedTodosList(TodosOverviewState state) {
    final List<Widget> items = [];

    for (final dateKey in _dateKeys) {
      final todos = _groupedTodos[dateKey] ?? [];
      if (todos.isEmpty) continue;

      // 添加日期分隔符
      items.add(_buildDateSeparator(dateKey));

      // 添加该日期下的所有待办
      for (final todo in todos) {
        items.add(
          TodoListTile(
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
            },
            onTap: () {
              Navigator.of(context).push(
                EditTodoPage.route(initialTodo: todo),
              );
            },
            // 子待办专用回调
            onSubtodoToggleCompleted: (subtodo) {
              context.read<TodosOverviewBloc>().add(
                    TodosOverviewTodoCompletionToggled(
                      todo: subtodo,
                      isCompleted: subtodo.isCompleted,
                    ),
                  );
            },
            onSubtodoDismissed: (subtodo) {
              context.read<TodosOverviewBloc>().add(
                    TodosOverviewTodoDeleted(subtodo),
                  );
            },
            onSubtodoTap: (subtodo) {
              Navigator.of(context).push(
                EditTodoPage.route(initialTodo: subtodo),
              );
            },
            onSubtodoLongPress: (subtodo) {
              // 可以添加长按处理逻辑
            },
          ),
        );
      }
    }

    // 添加底部加载指示器
    items.add(_buildBottomLoader());

    return ListView(
      controller: _scrollController,
      children: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的待办'),
        actions: const [
          TodosOverviewFilterButton(),
          TodosOverviewOptionsButton(),
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
                    const SnackBar(
                      content: Text('待办错误信息'),
                    ),
                  );
              }
            },
          ),
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedTodo != current.lastDeletedTodo &&
                current.lastDeletedTodo != null,
            listener: (context, state) {
              // final deletedTodo = state.lastDeletedTodo!;
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: const Text(
                      // l10n.todosOverviewTodoDeletedSnackbarText(
                      //   deletedTodo.title,
                      // ),
                      '删除指定待办',
                    ),
                    action: SnackBarAction(
                      label: '撤销',
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
        child: BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
          builder: (context, state) {
            if (state.todos.isEmpty) {
              if (state.status == TodosOverviewStatus.loading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state.status != TodosOverviewStatus.success) {
                return const SizedBox();
              } else {
                return Center(
                  child: Text(
                    '暂无待办',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
            }

            // 初始化或重置分组数据
            _initializeGroupedData(state);

            return CupertinoScrollbar(
              controller: _scrollController,
              child: _buildGroupedTodosList(state),
            );
          },
        ),
      ),
    );
  }
}
