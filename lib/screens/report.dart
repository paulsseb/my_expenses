import 'package:built_collection/built_collection.dart';
import 'package:my_expenses/models/category_model.dart';
import 'package:my_expenses/models/expense_model.dart';
import 'package:my_expenses/db/services/category_service.dart';
import 'package:my_expenses/db/services/expense_service.dart';
import 'package:my_expenses/blocs/category_bloc.dart';
import 'package:my_expenses/blocs/expense_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  ExpenseBloc _expenseBloc;
  CategoryBloc _categoryBloc;
  TooltipBehavior _categoryTooltip;
  TooltipBehavior _timeTooltip;
  Stream<List<dynamic>> _reportStream;

  @override
  void initState() {
    super.initState();
    _expenseBloc = ExpenseBloc(ExpenseService());
    _categoryBloc = CategoryBloc(CategoryService());
    _expenseBloc.getExpenses();
    _categoryTooltip = TooltipBehavior(enable: true);
    _timeTooltip = TooltipBehavior(enable: true);
    _reportStream = Rx.combineLatest2(
        _categoryBloc.categoryListStream,
        _expenseBloc.expenseListStream,
        (BuiltList<CategoryModel> cats, BuiltList<ExpenseModel> exps) =>
            [cats, exps]);
  }

  @override
  Widget build(BuildContext context) {
    return _getReportTab();
  }

  Widget _getReportTab() {
    return StreamBuilder<List<dynamic>>(
      stream: _reportStream,
      builder: (_, AsyncSnapshot<List<dynamic>> snap) {
        if (snap.hasError) {
          return Center(child: Text("Couldn't load report: ${snap.error}"));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        BuiltList<CategoryModel> categories = snap.data[0];
        BuiltList<ExpenseModel> expenses = snap.data[1];

        if (expenses.isEmpty) {
          return const Center(
              child: Text("No expenses yet. Add some to see your report."));
        }

        var categoryData = _categoryBreakdown(categories, expenses);
        var timeData = _dailyTotals(expenses);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 0),
                child: Text("Spending by Category",
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  tooltipBehavior: _categoryTooltip,
                  series: <ChartSeries<_ChartData, String>>[
                    ColumnSeries<_ChartData, String>(
                      dataSource: categoryData,
                      xValueMapper: (_ChartData d, _) => d.x,
                      yValueMapper: (_ChartData d, _) => d.y,
                      name: 'Spend',
                      color: const Color.fromRGBO(8, 142, 255, 1),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 0),
                child: Text("Spending Over Time",
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  tooltipBehavior: _timeTooltip,
                  series: <ChartSeries<_ChartData, String>>[
                    LineSeries<_ChartData, String>(
                      dataSource: timeData,
                      xValueMapper: (_ChartData d, _) => d.x,
                      yValueMapper: (_ChartData d, _) => d.y,
                      name: 'Daily total',
                      markerSettings: const MarkerSettings(isVisible: true),
                      color: const Color.fromRGBO(255, 108, 8, 1),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }

  List<_ChartData> _categoryBreakdown(
      BuiltList<CategoryModel> categories, BuiltList<ExpenseModel> expenses) {
    var totalsByCategoryId = <int, double>{};
    for (var expense in expenses) {
      var categoryId = expense.categoryId ?? 0;
      totalsByCategoryId[categoryId] =
          (totalsByCategoryId[categoryId] ?? 0) + (expense.amount ?? 0);
    }

    var data = totalsByCategoryId.entries.map((entry) {
      var category = categories.firstWhere((c) => c.id == entry.key,
          orElse: () => null);
      return _ChartData(category?.title ?? "Uncategorized", entry.value);
    }).toList();

    data.sort((a, b) => b.y.compareTo(a.y));
    return data;
  }

  List<_ChartData> _dailyTotals(BuiltList<ExpenseModel> expenses) {
    var totalsByDate = <String, double>{};
    for (var expense in expenses) {
      var date = expense.date ?? "Unknown";
      totalsByDate[date] = (totalsByDate[date] ?? 0) + (expense.amount ?? 0);
    }

    var sortedDates = totalsByDate.keys.toList()..sort();
    return sortedDates
        .map((date) => _ChartData(date, totalsByDate[date]))
        .toList();
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
