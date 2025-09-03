import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../edit_todo.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:intl/intl.dart';

class EditTodoPage extends StatelessWidget {
  const EditTodoPage({super.key});

  static Route<void> route({Todo? initialTodo, DateTime? defaultCreatedAt, String? parentTodoId}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => EditTodoBloc(
          todosRepository: context.read<TodosRepository>(),
          initialTodo: initialTodo,
          defaultCreatedAt: defaultCreatedAt,
          parentTodoId: parentTodoId,
        ),
        child: const EditTodoPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditTodoBloc, EditTodoState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == EditTodoStatus.success,
      listener: (context, state) => Navigator.of(context).pop(),
      child: const EditTodoView(),
    );
  }
}

class EditTodoView extends StatelessWidget {
  const EditTodoView({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select((EditTodoBloc bloc) => bloc.state.status);
    final isNewTodo = context.select(
      (EditTodoBloc bloc) => bloc.state.isNewTodo,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewTodo ? '添加待办' : '编辑待办',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'editTodoSaveButtonTooltip',
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        onPressed: status.isLoadingOrSuccess
            ? null
            : () => context.read<EditTodoBloc>().add(const EditTodoSubmitted()),
        child: status.isLoadingOrSuccess
            ? const CupertinoActivityIndicator()
            : const Icon(Icons.check_rounded),
      ),
      body: const CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _TitleField(),
                SizedBox(height: 16),
                _DescriptionField(),
                SizedBox(height: 16),
                _FocusTimeField(),
                SizedBox(height: 16),
                _CreatedAtField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusTimeField extends StatelessWidget {
  const _FocusTimeField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;

    return TextFormField(
      key: const Key('editTodoView_focusTime_textFormField'),
      initialValue: state.focusTime.toString(),
      decoration: const InputDecoration(
        labelText: '专注时间（分钟）',
        hintText: '输入专注时间',
        suffixIcon: Icon(Icons.timer),
      ),
      enabled: !state.status.isLoadingOrSuccess,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      onChanged: (value) {
        final focusTime = int.tryParse(value) ?? 0;
        context.read<EditTodoBloc>().add(EditTodoFocusTimeChanged(focusTime));
      },
    );
  }
}

class _CreatedAtField extends StatefulWidget {
  const _CreatedAtField();

  @override
  State<_CreatedAtField> createState() => _CreatedAtFieldState();
}

class _CreatedAtFieldState extends State<_CreatedAtField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;
    final formattedDate =
        DateFormat('yyyy-MM-dd HH:mm').format(state.createdAt);

    // 更新controller的文本
    _controller.text = formattedDate;

    return TextFormField(
      key: const Key('editTodoView_createdAt_textFormField'),
      controller: _controller,
      decoration: const InputDecoration(
        labelText: '创建时间',
        hintText: '点击选择日期',
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: state.status.isLoadingOrSuccess
          ? null
          : () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.createdAt,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                // 保持原有的时间部分
                final newDateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  state.createdAt.hour,
                  state.createdAt.minute,
                );
                context
                    .read<EditTodoBloc>()
                    .add(EditTodoCreatedAtChanged(newDateTime));
              }
            },
    );
  }
}

class _TitleField extends StatelessWidget {
  const _TitleField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;
    final hintText = state.initialTodo?.title ?? '';

    return TextFormField(
      key: const Key('editTodoView_title_textFormField'),
      initialValue: state.title,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '标题',
        hintText: hintText.isEmpty ? '输入待办标题' : hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      onChanged: (value) {
        context.read<EditTodoBloc>().add(EditTodoTitleChanged(value));
      },
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;
    final hintText = state.initialTodo?.description ?? '';

    return TextFormField(
      key: const Key('editTodoView_description_textFormField'),
      initialValue: state.description,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '描述',
        hintText: hintText.isEmpty ? '输入待办描述' : hintText,
      ),
      maxLength: 300,
      maxLines: 7,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      onChanged: (value) {
        context.read<EditTodoBloc>().add(EditTodoDescriptionChanged(value));
      },
    );
  }
}
