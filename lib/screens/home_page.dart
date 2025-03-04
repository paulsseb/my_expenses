import 'package:flutter/material.dart';
import 'package:my_expenses/screens/category.dart';
import 'package:my_expenses/screens/dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // Use 'late' to avoid null safety issues.

  final List<String> _tabs = ["Home", "Category", "Report"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose of the controller to avoid memory leaks.
    super.dispose();
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
        children: [
          DashboardPage(), // Removed 'const' if DashboardPage isn't a constant widget.
          CategoryPage(), 
          Center(
            child: Text(
              "Reports",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ],
      ),
    );
  }
}
