/// A repository that handles `todo` related requests.
library todos_repository;

/// 从 `todo`s_api 重新导出相同的 `Todo` 模型，而不是在 `todo`s_repository 中重新定义一个单独的模型
export 'package:todos_api/todos_api.dart' show Todo;
export 'src/todos_repository.dart';
