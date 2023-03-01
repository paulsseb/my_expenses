import 'package:my_expenses/screens/category.dart';
import 'package:my_expenses/screens/dashboard_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  final List<String> _tabs = ["Home", "Category", "Report"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Expense Manager"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.category)),
              Tab(icon: Icon(Icons.report)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            const DashboardPage(),
            CategoryPage(),
            Center(
                child: Text(
              "Reports",
              style: Theme.of(context).textTheme.bodyText1,
            ))
          ],
        ));
  }
}
