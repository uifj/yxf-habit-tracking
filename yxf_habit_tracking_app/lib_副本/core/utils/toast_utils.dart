import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 单例模式：使用 static FToast? fToast确保全局唯一实例
class ToastUtils {
  static FToast? fToast;

  //  初始化方法（必须在显示 Toast 前调用）
  static void init(BuildContext context) {
    if (fToast == null) {
      fToast = FToast();
      fToast!.init(context);
    }
  }

  static void toast(String msg) {
    //  创建自定义 Toast Widget
    Widget toastItem = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black45,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );

    // 显示 Toast
    fToast?.showToast(
      gravity: ToastGravity.BOTTOM,
      child: toastItem,
    );
  }
}
