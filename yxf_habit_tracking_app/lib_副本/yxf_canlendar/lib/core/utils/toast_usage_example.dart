import 'package:flutter/material.dart';
import 'toast_util.dart';

/// ToastUtil使用示例
/// 展示如何在Flutter应用中使用企业级Toast组件
class ToastUsageExample extends StatefulWidget {
  const ToastUsageExample({super.key});

  @override
  State<ToastUsageExample> createState() => _ToastUsageExampleState();
}

class _ToastUsageExampleState extends State<ToastUsageExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toast使用示例'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Toast提示示例',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // 基础用法示例
            _buildSection(
              '基础用法',
              [
                _buildButton(
                  '成功提示',
                  Colors.green,
                  () => ToastUtil.success('操作成功！'),
                ),
                _buildButton(
                  '错误提示',
                  Colors.red,
                  () => ToastUtil.error('操作失败，请重试'),
                ),
                _buildButton(
                  '警告提示',
                  Colors.orange,
                  () => ToastUtil.warning('请注意数据安全'),
                ),
                _buildButton(
                  '信息提示',
                  Colors.blue,
                  () => ToastUtil.info('这是一条信息提示'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 加载提示示例
            _buildSection(
              '加载提示',
              [
                _buildButton(
                  '显示加载',
                  Colors.grey,
                  () => ToastUtil.loading('正在处理中...'),
                ),
                _buildButton(
                  '隐藏加载',
                  Colors.grey[600]!,
                  () => ToastUtil.hide(),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 自定义配置示例
            _buildSection(
              '自定义配置',
              [
                _buildButton(
                  '顶部提示',
                  Colors.purple,
                  () => ToastUtil.success(
                    '这是顶部提示',
                    config: const ToastConfig(
                      position: ToastPosition.top,
                      duration: Duration(seconds: 3),
                    ),
                  ),
                ),
                _buildButton(
                  '底部提示',
                  Colors.teal,
                  () => ToastUtil.info(
                    '这是底部提示',
                    config: const ToastConfig(
                      position: ToastPosition.bottom,
                      duration: Duration(seconds: 3),
                    ),
                  ),
                ),
                _buildButton(
                  '自定义样式',
                  Colors.indigo,
                  () => ToastUtil.success(
                    '自定义样式的提示',
                    config: ToastConfig(
                      backgroundColor: Colors.indigo.withOpacity(0.9),
                      textColor: Colors.white,
                      fontSize: 16,
                      borderRadius: BorderRadius.circular(20),
                      maxWidth: 300,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 扩展方法示例
            _buildSection(
              '扩展方法',
              [
                _buildButton(
                  '字符串扩展',
                  Colors.deepOrange,
                  () => '使用字符串扩展方法显示提示'.showSuccess(),
                ),
              ],
            ),
            
            const Spacer(),
            
            // 使用说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '使用说明：',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. 在main.dart中初始化ToastUtil\n'
                    '2. 支持成功、错误、警告、信息、加载五种类型\n'
                    '3. 可自定义位置、颜色、字体等样式\n'
                    '4. 支持触觉反馈和点击关闭\n'
                    '5. 提供字符串扩展方法便于使用',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: children,
        ),
      ],
    );
  }
  
  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }
}

/// 应用初始化示例
/// 展示如何在main.dart中正确初始化ToastUtil
class ToastInitExample {
  /// 在main.dart中的使用示例
  static Widget buildApp() {
    // 创建全局导航键
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    
    // 初始化ToastUtil
    ToastUtil.init(navigatorKey);
    
    return MaterialApp(
      title: 'Toast Demo',
      navigatorKey: navigatorKey, // 重要：设置导航键
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ToastUsageExample(),
    );
  }
}

/// 实际业务场景使用示例
class BusinessUsageExample {
  /// 网络请求成功
  static void onNetworkSuccess(String message) {
    ToastUtil.success(message);
  }
  
  /// 网络请求失败
  static void onNetworkError(String error) {
    ToastUtil.error('网络请求失败: $error');
  }
  
  /// 表单验证警告
  static void onValidationWarning(String warning) {
    ToastUtil.warning(warning);
  }
  
  /// 显示加载状态
  static void showLoading() {
    ToastUtil.loading('正在加载中...');
  }
  
  /// 隐藏加载状态
  static void hideLoading() {
    ToastUtil.hide();
  }
  
  /// 异步操作示例
  static Future<void> performAsyncOperation() async {
    try {
      // 显示加载提示
      showLoading();
      
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 2));
      
      // 隐藏加载提示
      hideLoading();
      
      // 显示成功提示
      onNetworkSuccess('操作完成');
    } catch (e) {
      // 隐藏加载提示
      hideLoading();
      
      // 显示错误提示
      onNetworkError(e.toString());
    }
  }
}