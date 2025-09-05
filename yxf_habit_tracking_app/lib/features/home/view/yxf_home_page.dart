import 'package:flutter/material.dart';
import 'package:yxf_habit_tracking_app/app/theme/extensions/theme_extensions.dart';
import 'package:yxf_habit_tracking_app/common/widgets/widgets.dart';

class YxfHomePage extends StatefulWidget {
  const YxfHomePage({super.key});

  @override
  State<YxfHomePage> createState() => _YxfHomePageState();
}

class _YxfHomePageState extends State<YxfHomePage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      isDarkMode: context.isDarkMode,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('有限风-习惯追踪App'),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Today ${DateTime.now().day}'),
                              Icon(Icons.check_circle_outline),
                            ],
                          ),
                          Text('0/1'),
                          Text('0% completion rate'),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Today ${DateTime.now().day}'),
                              Icon(Icons.check_circle_outline),
                            ],
                          ),
                          Text('0/1'),
                          Text('0% completion rate'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Today ${DateTime.now().day}'),
                              Icon(Icons.check_circle_outline),
                            ],
                          ),
                          Text('0/1'),
                          Text('0% completion rate'),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Today ${DateTime.now().day}'),
                              Icon(Icons.check_circle_outline),
                            ],
                          ),
                          Text('0/1'),
                          Text('0% completion rate'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              HomeTabBarView(),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTabBarView extends StatefulWidget {
  const HomeTabBarView({super.key});

  @override
  State<HomeTabBarView> createState() => _HomeTabBarState();
}

class _HomeTabBarState extends State<HomeTabBarView>
    with SingleTickerProviderStateMixin {
  final List<Tab> tabs = [
    Tab(text: 'Goals'),
    Tab(text: 'habit'),
    Tab(text: 'Todos'),
    Tab(text: 'Reflection'),
  ];
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          height: 200,
          color: Colors.white,
          child: TabBarView(
            controller: _tabController,
            children: tabs.map((tab) => Text(tab.text!)).toList(),
          ),
        ),
      ],
    );
  }
}
