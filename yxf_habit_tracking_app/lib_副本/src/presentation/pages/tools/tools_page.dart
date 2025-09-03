import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_state_widget.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_theme_widget.dart';
import 'package:tencent_cloud_chat_common/data/theme/color/color_base.dart';
import 'package:tencent_cloud_chat_common/data/theme/text_style/text_style.dart';
import '../../widgets/custom_check_box.dart';

/// 工具页面 - 代码提取工具
/// 企业级Flutter开发标准实现
class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends TencentCloudChatState<ToolsPage> {
  // 控制器和焦点节点
  late final TextEditingController _headerController;
  late final TextEditingController _suffixController;
  late final FocusNode _headerFocusNode;
  late final FocusNode _suffixFocusNode;

  // 状态变量
  String? _headerError;
  String? _suffixError;
  Color _directoryFocusColor = Colors.grey;
  bool _isProcessing = false;
  Directory? _selectedDirectory;
  final List<String> _codeSuffixes = ['dart'];
  bool _removeAnnotation = true;
  bool _removeEmptyLine = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  /// 初始化控制器
  void _initializeControllers() {
    _headerController = TextEditingController();
    _suffixController = TextEditingController();
    _headerFocusNode = FocusNode();
    _suffixFocusNode = FocusNode();
  }

  /// 释放控制器
  void _disposeControllers() {
    _headerController.dispose();
    _suffixController.dispose();
    _headerFocusNode.dispose();
    _suffixFocusNode.dispose();
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) =>
          _buildContent(colorTheme, textStyle),
    );
  }

  @override
  Widget? mobileBuilder(BuildContext context) {
    return defaultBuilder(context);
  }

  @override
  Widget? desktopBuilder(BuildContext context) {
    return defaultBuilder(context);
  }

  /// 构建主要内容
  Widget _buildContent(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Scaffold(
      backgroundColor: colorTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          '代码提取工具',
          style: TextStyle(
            fontSize: textStyle.fontsize_18,
            fontWeight: FontWeight.bold,
            color: colorTheme.onBackground,
          ),
        ),
        backgroundColor: colorTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(colorTheme, textStyle),
    );
  }

  /// 构建主体内容
  Widget _buildBody(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderSection(colorTheme, textStyle),
              const SizedBox(height: 24),
              _buildDirectorySection(colorTheme, textStyle),
              const SizedBox(height: 24),
              _buildSuffixSection(colorTheme, textStyle),
              const SizedBox(height: 24),
              _buildOptionsSection(colorTheme, textStyle),
              const SizedBox(height: 32),
              _buildActionButton(colorTheme, textStyle),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标题输入区域
  Widget _buildHeaderSection(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '文档标题',
          style: TextStyle(
            fontSize: textStyle.fontsize_16,
            fontWeight: FontWeight.w600,
            color: colorTheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _headerController,
          focusNode: _headerFocusNode,
          decoration: InputDecoration(
            hintText: '请输入文档标题',
            errorText: _headerError,
            prefixIcon: Icon(Icons.title, color: colorTheme.primaryColor),
            border: _buildInputBorder(colorTheme.onBackground.withOpacity(0.3)),
            enabledBorder:
                _buildInputBorder(colorTheme.onBackground.withOpacity(0.3)),
            focusedBorder: _buildInputBorder(colorTheme.primaryColor),
            errorBorder: _buildInputBorder(Colors.red),
            filled: true,
            fillColor: colorTheme.backgroundColor,
          ),
          onChanged: (_) => _clearHeaderError(),
        ),
      ],
    );
  }

  /// 构建目录选择区域
  Widget _buildDirectorySection(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择代码目录',
          style: TextStyle(
            fontSize: textStyle.fontsize_16,
            fontWeight: FontWeight.w600,
            color: colorTheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDirectory,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: _directoryFocusColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: colorTheme.backgroundColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 48,
                  color: _directoryFocusColor,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedDirectory == null ? '点击选择代码目录' : '已选择目录',
                  style: TextStyle(
                    color: _directoryFocusColor,
                    fontSize: textStyle.fontsize_14,
                  ),
                ),
                if (_selectedDirectory != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _selectedDirectory!.path,
                      style: TextStyle(
                        color: colorTheme.onBackground.withOpacity(0.7),
                        fontSize: textStyle.fontsize_12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建后缀名输入区域
  Widget _buildSuffixSection(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '文件后缀名',
          style: TextStyle(
            fontSize: textStyle.fontsize_16,
            fontWeight: FontWeight.w600,
            color: colorTheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _suffixController,
          focusNode: _suffixFocusNode,
          decoration: InputDecoration(
            hintText: '输入文件后缀名后按回车',
            errorText: _suffixError,
            prefixIcon: Icon(Icons.code, color: colorTheme.primaryColor),
            border: _buildInputBorder(colorTheme.onBackground.withOpacity(0.3)),
            enabledBorder:
                _buildInputBorder(colorTheme.onBackground.withOpacity(0.3)),
            focusedBorder: _buildInputBorder(colorTheme.primaryColor),
            errorBorder: _buildInputBorder(Colors.red),
            filled: true,
            fillColor: colorTheme.backgroundColor,
          ),
          onSubmitted: _addSuffix,
        ),
        const SizedBox(height: 12),
        _buildSuffixChips(colorTheme, textStyle),
      ],
    );
  }

  /// 构建后缀名标签
  Widget _buildSuffixChips(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorTheme.onBackground.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: colorTheme.backgroundColor,
      ),
      child: _codeSuffixes.isEmpty
          ? Text(
              '请添加需要提取的文件后缀名',
              style: TextStyle(
                color: colorTheme.onBackground.withOpacity(0.5),
                fontSize: textStyle.fontsize_14,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _codeSuffixes.map((suffix) {
                return Chip(
                  label: Text(suffix),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeSuffix(suffix),
                  backgroundColor: colorTheme.primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: colorTheme.primaryColor,
                    fontSize: textStyle.fontsize_12,
                  ),
                );
              }).toList(),
            ),
    );
  }

  /// 构建选项区域
  Widget _buildOptionsSection(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '处理选项',
          style: TextStyle(
            fontSize: textStyle.fontsize_16,
            fontWeight: FontWeight.w600,
            color: colorTheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomCheckBox(
                value: _removeAnnotation,
                label: '去除注释',
                onChanged: (value) =>
                    safeSetState(() => _removeAnnotation = value),
              ),
            ),
            Expanded(
              child: CustomCheckBox(
                value: _removeEmptyLine,
                label: '去除空行',
                onChanged: (value) =>
                    safeSetState(() => _removeEmptyLine = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _startExtractCode,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isProcessing
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              '开始提取代码',
              style: TextStyle(
                fontSize: textStyle.fontsize_16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  /// 构建输入框边框
  OutlineInputBorder _buildInputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  /// 选择目录
  Future<void> _selectDirectory() async {
    try {
      final String? directoryPath =
          await FilePicker.platform.getDirectoryPath();
      if (directoryPath != null) {
        safeSetState(() {
          _selectedDirectory = Directory(directoryPath);
          _directoryFocusColor = Colors.green;
        });
      }
    } catch (e) {
      _showErrorMessage('选择目录失败: $e');
    }
  }

  /// 添加后缀名
  void _addSuffix(String suffix) {
    final trimmedSuffix = suffix.trim();
    if (trimmedSuffix.isEmpty) return;

    if (_codeSuffixes.contains(trimmedSuffix)) {
      _showErrorMessage('后缀名已存在');
    } else {
      safeSetState(() {
        _codeSuffixes.add(trimmedSuffix);
        _suffixController.clear();
        _suffixError = null;
      });
    }
    _suffixFocusNode.requestFocus();
  }

  /// 移除后缀名
  void _removeSuffix(String suffix) {
    safeSetState(() {
      _codeSuffixes.remove(suffix);
    });
  }

  /// 清除标题错误
  void _clearHeaderError() {
    if (_headerError != null) {
      safeSetState(() => _headerError = null);
    }
  }

  /// 开始提取代码
  Future<void> _startExtractCode() async {
    if (!_validateInputs()) return;

    safeSetState(() => _isProcessing = true);

    try {
      final String content = await _extractCodeContent();
      await _generateDocument(content);
      _showSuccessMessage('代码提取完成！');
    } catch (e) {
      _showErrorMessage('提取失败: $e');
    } finally {
      safeSetState(() => _isProcessing = false);
    }
  }

  /// 验证输入
  bool _validateInputs() {
    bool isValid = true;

    if (_headerController.text.trim().isEmpty) {
      safeSetState(() => _headerError = '请输入文档标题');
      _headerFocusNode.requestFocus();
      isValid = false;
    }

    if (_selectedDirectory == null) {
      safeSetState(() => _directoryFocusColor = Colors.red);
      _showErrorMessage('请选择代码目录');
      isValid = false;
    }

    if (_codeSuffixes.isEmpty) {
      safeSetState(() => _suffixError = '请添加至少一个文件后缀名');
      _suffixFocusNode.requestFocus();
      isValid = false;
    }

    return isValid;
  }

  /// 提取代码内容
  Future<String> _extractCodeContent() async {
    final List<FileSystemEntity> entities =
        await _selectedDirectory!.list().toList();
    final StringBuffer contentBuffer = StringBuffer();

    for (final entity in entities) {
      final String content = await _readPath(entity);
      contentBuffer.write(content);
    }

    String content = contentBuffer.toString();

    // 处理内容
    if (_removeAnnotation) {
      content = _removeAnnotationFromCode(content);
    }

    return content;
  }

  /// 递归读取文件路径
  Future<String> _readPath(FileSystemEntity item) async {
    FileStat stat = await item.stat();
    String content = '';

    if (stat.type == FileSystemEntityType.directory) {
      Directory dir = Directory(item.path);
      List<FileSystemEntity> list = await dir.list().toList();
      for (FileSystemEntity entity in list) {
        content += await _readPath(entity);
      }
    } else {
      File file = File(item.path);
      String extname = path.extension(item.path);
      extname = extname.isEmpty ? '' : extname.substring(1);
      if (_codeSuffixes.contains(extname)) {
        try {
          content += await file.readAsString();
        } catch (e) {
          // 忽略无法读取的文件
        }
      }
    }

    return content;
  }

  /// 生成文档
  Future<void> _generateDocument(String content) async {
    try {
      // HTML转义处理
      content = content.replaceAll('<', '&#60;').replaceAll('>', '&#62;');
      content = content.replaceAll('\n\r', '\n');

      // 格式化内容为HTML格式
      List<String> strList = [];
      content.split('\n').forEach((item) {
        String str = item.trimRight(); // 去除右边空格
        strList.add(str.replaceAll(' ', '&#160;')); // 空格转义
        strList.add('<br/>');
      });

      // 去除空行处理
      if (_removeEmptyLine) {
        strList = strList.where((element) {
          String text = element.trim();
          if (text.isEmpty) return false;

          text = text.replaceAll('&#160;', '');
          if (text.isEmpty) return false;

          text = text.replaceAll('<br/>', '');
          if (text.isEmpty) return false;

          return true;
        }).toList();
      }

      content = strList.join('<br/>');

      // 获取系统临时文件夹
      Directory tempDir = Directory.systemTemp;

      // 提取Word模板资源
      ByteData data = await rootBundle.load('assets/tpl.docx');
      File docFile = File(path.join(tempDir.path, 'copyright_gen_tpl.docx'));
      await docFile.writeAsBytes(data.buffer.asUint8List());
      Uint8List bytes = docFile.readAsBytesSync();

      // 解压Word文档
      Archive zip = ZipDecoder().decodeBytes(bytes);
      String zipExtName = path.join(tempDir.path, _generateRandomId());
      Directory zipDir = Directory(zipExtName);
      await zipDir.create();

      // 处理Word文档内容
      for (ArchiveFile file in zip.files) {
        if (file.isFile) {
          File f = File(path.join(zipExtName, file.name));
          Directory d = Directory(path.dirname(f.path));
          await d.create(recursive: true);
          String tpl = _bytesToString(file.content);
          tpl = tpl.replaceAll('{{content}}', content);
          tpl = tpl.replaceAll('{{header}}', _headerController.text);
          await f.writeAsString(tpl);
        } else {
          Directory d = Directory(path.join(zipExtName, file.name));
          await d.create(recursive: true);
        }
      }

      // 重新压缩为Word文档
      File zipFile =
          File(path.join(tempDir.path, '${_generateRandomId()}.zip'));
      ZipFileEncoder newZip = ZipFileEncoder();
      newZip.create(zipFile.path);
      newZip.addDirectory(zipDir, includeDirName: false);
      newZip.close();

      // 生成最终的Word文档
      Directory rootDir = Directory.current;
      int now = DateTime.now().millisecondsSinceEpoch;
      Uint8List docData = await zipFile.readAsBytes();
      File finalDocFile = File(path.join(rootDir.path, 'output_$now.docx'));
      await finalDocFile.writeAsBytes(docData);

      // 清理临时文件
      await zipDir.delete(recursive: true);
      await docFile.delete();
      await zipFile.delete();

      // 显示成功对话框
      if (mounted) {
        _showSuccessDialog(finalDocFile.path);
      }
    } catch (e) {
      throw Exception('文档生成失败: $e');
    }
  }

  /// 移除注释
  String _removeAnnotationFromCode(String code) {
    String result = code;
    List<String> lines = code.split('\n');
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim(); // 去除字符串前后空白
      if (line.startsWith('//')) lines[i] = ''; // 如果是// 开头就清除当前行
    }
    result = lines.join('\n');

    // 删除多行注释
    RegExp regExp = RegExp(r'/\*{1,2}[\s\S]*?\*/');
    result = result.replaceAll(regExp, '');
    return result;
  }

  /// 显示错误消息
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 显示成功消息
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 显示成功对话框
  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('提取代码成功'),
          content: Text('文件已经生成在 $filePath'),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
            ElevatedButton(
              child: const Text('打开文档'),
              onPressed: () {
                if (Platform.isWindows) {
                  Process.run('start', [filePath], runInShell: true);
                } else if (Platform.isMacOS) {
                  Process.run('open', [filePath], runInShell: true);
                } else if (Platform.isLinux) {
                  Process.run('xdg-open', [filePath], runInShell: true);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// 生成随机ID
  String _generateRandomId() {
    var random = Random();
    var id = '';
    for (var i = 0; i < 10; i++) {
      id += random.nextInt(10).toString();
    }
    return 'copyright_gen_$id';
  }

  /// 字节数组转字符串
  String _bytesToString(Uint8List bytes) {
    return String.fromCharCodes(bytes);
  }
}
