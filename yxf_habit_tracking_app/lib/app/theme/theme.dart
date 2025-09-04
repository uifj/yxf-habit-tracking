// Theme module exports
// 主题模块导出文件

// Core theme files
export 'cubit/theme_cubit.dart';
export 'models/theme_models.dart';
export 'theme_factory.dart';

// Extensions
export 'extensions/theme_extensions.dart';

// Widgets
export 'widgets/theme_builder.dart';

// Legacy theme implementation
// import 'package:flutter/material.dart';

/// Legacy theme class for backward compatibility
/// 向后兼容的旧版主题类
// class AppTheme {
//   static ThemeData get light {
//     return ThemeData(
//       appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 117, 208, 247)),
//       colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF13B9FF)),
//       snackBarTheme: const SnackBarThemeData(
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   static ThemeData get dark {
//     return ThemeData(
//       appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 16, 46, 59)),
//       colorScheme: ColorScheme.fromSeed(
//         brightness: Brightness.dark,
//         seedColor: const Color(0xFF13B9FF),
//       ),
//       snackBarTheme: const SnackBarThemeData(
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
// }

