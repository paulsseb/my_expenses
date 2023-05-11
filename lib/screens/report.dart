import 'package:built_collection/built_collection.dart';
import 'package:my_expenses/models/expense_model.dart';
import 'package:my_expenses/db/services/expense_service.dart';
import 'package:my_expenses/blocs/expense_bloc.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  ExpenseBloc _expenseBloc;
  List<_ChartData> data;
  TooltipBehavior _tooltip;

  @override
  initState() {
    data = [
      _ChartData('CHN', 12),
      _ChartData('GER', 15),
      _ChartData('RUS', 30),
      _ChartData('BRZ', 6.4),
      _ChartData('IND', 14)
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
    _expenseBloc = ExpenseBloc(ExpenseService());
  }

  @override
  Widget build(BuildContext context) {
    return _getReportTab();
  }

  Widget _getReportTab() {
    return Column(
      children: <Widget>[
// Stream builder allows auto update of UI i.e. when items in db list are deleted
        StreamBuilder(
          stream: _expenseBloc.expenseListSelectDateStream,
          builder: (_, AsyncSnapshot<BuiltList<ExpenseModel>> expenseListSnap) {
            if (!expenseListSnap.hasData) {
              return const CircularProgressIndicator();
            }

            var lsCategories = expenseListSnap.data;

            return Expanded(
              child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis:
                      NumericAxis(minimum: 0, maximum: 40, interval: 10),
                  tooltipBehavior: _tooltip,
                  series: <ChartSeries<_ChartData, String>>[
                    ColumnSeries<_ChartData, String>(
                        dataSource: data,
                        xValueMapper: (_ChartData data, _) => data.x,
                        yValueMapper: (_ChartData data, _) => data.y,
                        name: 'Gold',
                        color: Color.fromRGBO(8, 142, 255, 1))
                  ]),
            );
          },
        ),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
