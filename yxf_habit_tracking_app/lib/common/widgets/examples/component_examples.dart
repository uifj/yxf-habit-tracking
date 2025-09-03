import 'package:flutter/material.dart';
import '../button/opacity_button.dart';
import '../modal/action_modal.dart';

/// 通用组件使用示例
class ComponentExamples extends StatelessWidget {
  const ComponentExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通用组件示例'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('透明背景按钮 (OpacityButton)'),
            const SizedBox(height: 16),
            _buildOpacityButtonExamples(context),
            
            const SizedBox(height: 32),
            _buildSectionTitle('底部动作弹窗 (ActionModal)'),
            const SizedBox(height: 16),
            _buildActionModalExamples(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOpacityButtonExamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '基础用法:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // 基础按钮
            OpacityButton(
              icon: Icons.add,
              onTap: () => _showSnackBar(context, '点击了添加按钮'),
            ),
            
            // 设置按钮
            OpacityButton(
              icon: Icons.settings,
              onTap: () => _showSnackBar(context, '点击了设置按钮'),
            ),
            
            // 搜索按钮
            OpacityButton(
              icon: Icons.search,
              onTap: () => _showSnackBar(context, '点击了搜索按钮'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        const Text(
          '自定义样式:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // 大尺寸按钮
            OpacityButton(
              icon: Icons.favorite,
              onTap: () => _showSnackBar(context, '大尺寸按钮'),
              size: 56,
              iconSize: 24,
              iconColor: Colors.red,
            ),
            
            // 小尺寸按钮
            OpacityButton(
              icon: Icons.star,
              onTap: () => _showSnackBar(context, '小尺寸按钮'),
              size: 32,
              iconSize: 16,
              borderRadius: 8,
            ),
            
            // 禁用状态
            OpacityButton(
              icon: Icons.lock,
              onTap: () {},
              enabled: false,
            ),
            
            // 自定义透明度
            OpacityButton(
              icon: Icons.palette,
              onTap: () => _showSnackBar(context, '自定义透明度'),
              backgroundOpacity: 0.2,
              borderOpacity: 0.4,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        const Text(
          '便捷函数用法:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            opacityButton(
              icon: Icons.share,
              onTap: () => _showSnackBar(context, '便捷函数创建的按钮'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionModalExamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '基础用法:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showBasicActionModal(context),
          child: const Text('显示基础动作弹窗'),
        ),
        
        const SizedBox(height: 12),
        const Text(
          '带标题的弹窗:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showTitledActionModal(context),
          child: const Text('显示带标题的弹窗'),
        ),
        
        const SizedBox(height: 12),
        const Text(
          '包含危险操作的弹窗:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showDestructiveActionModal(context),
          child: const Text('显示危险操作弹窗'),
        ),
        
        const SizedBox(height: 12),
        const Text(
          '自定义样式弹窗:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showCustomStyledActionModal(context),
          child: const Text('显示自定义样式弹窗'),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showBasicActionModal(BuildContext context) {
    showActionBottomModal(
      context: context,
      actions: [
        ActionModal(
          label: '分享',
          icon: Icons.share,
          onTap: () => _showSnackBar(context, '点击了分享'),
        ),
        ActionModal(
          label: '复制链接',
          icon: Icons.link,
          onTap: () => _showSnackBar(context, '点击了复制链接'),
        ),
        ActionModal(
          label: '收藏',
          icon: Icons.bookmark,
          onTap: () => _showSnackBar(context, '点击了收藏'),
        ),
      ],
    );
  }

  void _showTitledActionModal(BuildContext context) {
    showActionBottomModal(
      context: context,
      title: '选择操作',
      actions: [
        ActionModal(
          label: '编辑',
          icon: Icons.edit,
          onTap: () => _showSnackBar(context, '点击了编辑'),
        ),
        ActionModal(
          label: '移动',
          icon: Icons.drive_file_move,
          onTap: () => _showSnackBar(context, '点击了移动'),
        ),
        ActionModal(
          label: '重命名',
          icon: Icons.drive_file_rename_outline,
          onTap: () => _showSnackBar(context, '点击了重命名'),
        ),
      ],
    );
  }

  void _showDestructiveActionModal(BuildContext context) {
    showActionBottomModal(
      context: context,
      title: '文件操作',
      actions: [
        ActionModal(
          label: '下载',
          icon: Icons.download,
          onTap: () => _showSnackBar(context, '点击了下载'),
        ),
        ActionModal(
          label: '分享',
          icon: Icons.share,
          onTap: () => _showSnackBar(context, '点击了分享'),
        ),
        ActionModal(
          label: '删除',
          icon: Icons.delete,
          onTap: () => _showSnackBar(context, '点击了删除'),
          isDestructive: true,
        ),
      ],
    );
  }

  void _showCustomStyledActionModal(BuildContext context) {
    showActionBottomModal(
      context: context,
      title: '自定义样式',
      backgroundColor: Colors.grey[100],
      borderRadius: 24,
      actions: [
        ActionModal(
          label: '拍照',
          icon: Icons.camera_alt,
          onTap: () => _showSnackBar(context, '点击了拍照'),
          iconColor: Colors.blue,
          backgroundColor: Colors.blue.withOpacity(0.1),
        ),
        ActionModal(
          label: '从相册选择',
          icon: Icons.photo_library,
          onTap: () => _showSnackBar(context, '点击了从相册选择'),
          iconColor: Colors.green,
          backgroundColor: Colors.green.withOpacity(0.1),
        ),
        ActionModal(
          label: '取消',
          icon: Icons.close,
          onTap: () => _showSnackBar(context, '点击了取消'),
          textColor: Colors.grey[600],
        ),
      ],
    );
  }
}