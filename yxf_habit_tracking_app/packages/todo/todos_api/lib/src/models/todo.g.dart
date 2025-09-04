// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
      title: json['title'] as String,
      id: json['id'] as String?,
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      focusTime: (json['focusTime'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      subtodos: (json['subtodos'] as List<dynamic>?)
              ?.map((e) => Todo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      subtodosExpanded: json['subtodosExpanded'] as bool? ?? false,
      parentTodoId: json['parentTodoId'] as String?,
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'isCompleted': instance.isCompleted,
      'focusTime': instance.focusTime,
      'createdAt': instance.createdAt.toIso8601String(),
      'subtodos': instance.subtodos,
      'subtodosExpanded': instance.subtodosExpanded,
      'parentTodoId': instance.parentTodoId,
    };
