import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_state_widget.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_theme_widget.dart';
import 'package:tencent_cloud_chat_common/data/theme/color/color_base.dart';
import 'package:tencent_cloud_chat_common/data/theme/text_style/text_style.dart';
import '../../bloc/bloc.dart';
import '../../bloc/statistics/statistics_state.dart' as stats;

/// 数据分析页面
class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用全局提供的StatisticsBloc实例
    context.read<StatisticsBloc>().add(const StatisticsLoadRequested());
    return const _AnalysisPageView();
  }
}

class _AnalysisPageView extends StatefulWidget {
  const _AnalysisPageView({super.key});

  @override
  State<_AnalysisPageView> createState() => _AnalysisPageViewState();
}

class _AnalysisPageViewState extends TencentCloudChatState<_AnalysisPageView> {
  @override
  Widget defaultBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) => Scaffold(
        backgroundColor: colorTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, colorTheme, textStyle),
              Expanded(
                child: BlocBuilder<StatisticsBloc, StatisticsState>(
                  builder: (context, state) {
                    if (state is stats.StatisticsLoading) {
                      return _buildLoadingState(colorTheme);
                    } else if (state is stats.StatisticsError) {
                      return _buildErrorState(
                          colorTheme, textStyle, state.message);
                    } else if (state is stats.StatisticsLoaded) {
                      return _buildContent(
                          context, colorTheme, textStyle, state);
                    } else {
                      return _buildEmptyState(colorTheme, textStyle);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            '学习分析',
            style: TextStyle(
              fontSize: textStyle.fontsize_20,
              fontWeight: FontWeight.bold,
              color: colorTheme.onBackground,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<StatisticsBloc>()
                  .add(const StatisticsLoadRequested());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(TencentCloudChatThemeColors colorTheme) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(colorTheme.primaryColor),
      ),
    );
  }

  Widget _buildErrorState(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorTheme.onBackground.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: textStyle.fontsize_18,
              fontWeight: FontWeight.bold,
              color: colorTheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: textStyle.fontsize_14,
              color: colorTheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context
                  .read<StatisticsBloc>()
                  .add(const StatisticsLoadRequested());
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: colorTheme.onBackground.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(
              fontSize: textStyle.fontsize_18,
              color: colorTheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始练习后，这里将显示您的学习统计',
            style: TextStyle(
              fontSize: textStyle.fontsize_14,
              color: colorTheme.onBackground.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle,
      stats.StatisticsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计卡片
          _buildStatisticsCards(colorTheme, textStyle, state),
          const SizedBox(height: 24),

          // WPM 趋势图
          _buildSectionTitle('WPM 趋势', colorTheme, textStyle),
          const SizedBox(height: 12),
          _buildWPMChart(colorTheme, textStyle, state),
          const SizedBox(height: 24),

          // 准确率趋势图
          _buildSectionTitle('准确率趋势', colorTheme, textStyle),
          const SizedBox(height: 12),
          _buildAccuracyChart(colorTheme, textStyle, state),
          const SizedBox(height: 24),

          // 键盘热力图
          _buildSectionTitle('键盘错误分析', colorTheme, textStyle),
          const SizedBox(height: 12),
          _buildKeyboardHeatmap(colorTheme, textStyle, state),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle, stats.StatisticsLoaded state) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          '总单词数',
          '${state.data.overall.totalWords}',
          Icons.text_fields,
          colorTheme,
          textStyle,
        ),
        _buildStatCard(
          '平均 WPM',
          state.data.overall.averageWPM.toStringAsFixed(1),
          Icons.speed,
          colorTheme,
          textStyle,
        ),
        _buildStatCard(
          '平均准确率',
          '${state.data.overall.averageAccuracy.toStringAsFixed(1)}%',
          Icons.track_changes,
          colorTheme,
          textStyle,
        ),
        _buildStatCard(
          '连续天数',
          '${state.data.overall.streakDays} 天',
          Icons.local_fire_department,
          colorTheme,
          textStyle,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    TencentCloudChatThemeColors colorTheme,
    TencentCloudChatTextStyle textStyle,
  ) {
    return Card(
      color: colorTheme.backgroundColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: colorTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: textStyle.fontsize_20,
                fontWeight: FontWeight.bold,
                color: colorTheme.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: textStyle.fontsize_12,
                color: colorTheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Text(
      title,
      style: TextStyle(
        fontSize: textStyle.fontsize_18,
        fontWeight: FontWeight.bold,
        color: colorTheme.onBackground,
      ),
    );
  }

  Widget _buildWPMChart(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle, stats.StatisticsLoaded state) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorTheme.onBackground.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          'WPM 趋势图\n（图表组件待实现）',
          style: TextStyle(
            fontSize: textStyle.fontsize_14,
            color: colorTheme.onBackground.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAccuracyChart(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle, stats.StatisticsLoaded state) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorTheme.onBackground.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          '准确率趋势图\n（图表组件待实现）',
          style: TextStyle(
            fontSize: textStyle.fontsize_14,
            color: colorTheme.onBackground.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildKeyboardHeatmap(TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle, stats.StatisticsLoaded state) {
    final keyboardLayout = [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
    ];

    final keyboardData = state.data.keyboardHeatmap;
    final maxMistakes = keyboardData.values.isNotEmpty
        ? keyboardData.values
            .map((e) => e.wrongCount)
            .reduce((a, b) => a > b ? a : b)
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorTheme.onBackground.withOpacity(0.2)),
      ),
      child: Column(
        children: keyboardLayout.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                final mistakeCount = keyboardData[key]?.wrongCount ?? 0;
                final intensity =
                    maxMistakes > 0 ? mistakeCount / maxMistakes : 0.0;

                return Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: intensity > 0
                        ? Colors.red.withOpacity(0.2 + intensity * 0.6)
                        : colorTheme.onBackground.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: colorTheme.onBackground.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      key.toUpperCase(),
                      style: TextStyle(
                        fontSize: textStyle.fontsize_12,
                        fontWeight: FontWeight.bold,
                        color: intensity > 0.5
                            ? Colors.white
                            : colorTheme.onBackground,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget? mobileBuilder(BuildContext context) {
    return defaultBuilder(context);
  }

  @override
  Widget? desktopBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) => Scaffold(
        backgroundColor: colorTheme.backgroundColor,
        body: Row(
          children: [
            // 侧边栏（桌面端）
            Container(
              width: 300,
              color: colorTheme.desktopBackgroundColorLinearGradientOne,
              child: Column(
                children: [
                  _buildHeader(context, colorTheme, textStyle),
                  Expanded(
                    child: _buildSidebar(context, colorTheme, textStyle),
                  ),
                ],
              ),
            ),
            // 主内容区域
            Expanded(
              child: BlocBuilder<StatisticsBloc, StatisticsState>(
                builder: (context, state) {
                  if (state is stats.StatisticsLoaded) {
                    return _buildContent(context, colorTheme, textStyle, state);
                  } else if (state is stats.StatisticsLoading) {
                    return _buildLoadingState(colorTheme);
                  } else if (state is stats.StatisticsError) {
                    return _buildErrorState(
                        colorTheme, textStyle, state.message);
                  } else {
                    return _buildEmptyState(colorTheme, textStyle);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(
      BuildContext context,
      TencentCloudChatThemeColors colorTheme,
      TencentCloudChatTextStyle textStyle) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '时间范围',
            style: TextStyle(
              color: colorTheme.onBackground,
              fontSize: textStyle.fontsize_16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeRangeButton('最近7天', true, colorTheme, textStyle),
          _buildTimeRangeButton('最近30天', false, colorTheme, textStyle),
          _buildTimeRangeButton('最近3个月', false, colorTheme, textStyle),
          _buildTimeRangeButton('全部时间', false, colorTheme, textStyle),
          const SizedBox(height: 24),
          Text(
            '导出数据',
            style: TextStyle(
              color: colorTheme.onBackground,
              fontSize: textStyle.fontsize_16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: 导出学习数据
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorTheme.primaryColor,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              '导出 CSV',
              style: TextStyle(
                color: Colors.white,
                fontSize: textStyle.fontsize_14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(
    String title,
    bool isSelected,
    TencentCloudChatThemeColors colorTheme,
    TencentCloudChatTextStyle textStyle,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: TextButton(
        onPressed: () {
          // TODO: 切换时间范围
        },
        style: TextButton.styleFrom(
          backgroundColor:
              isSelected ? colorTheme.primaryColor : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? colorTheme.primaryColor
                  : colorTheme.onBackground.withOpacity(0.3),
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : colorTheme.onBackground,
            fontSize: textStyle.fontsize_14,
          ),
        ),
      ),
    );
  }
}
