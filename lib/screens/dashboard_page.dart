import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/models/expense_model.dart';
import 'package:my_expenses/screens/add_expense.dart';
import 'package:built_collection/built_collection.dart';
import 'package:my_expenses/db/services/expense_service.dart';

import 'package:my_expenses/db/services/category_service.dart';
import 'package:my_expenses/blocs/category_bloc.dart';
import 'package:my_expenses/blocs/expense_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ExpenseBloc _expenseBloc;
  CategoryBloc _categoryBloc;
  String _selectedDate;

  @override
  initState() {
    super.initState();
    _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _expenseBloc = ExpenseBloc(ExpenseService());
    _categoryBloc = CategoryBloc(CategoryService());
  }

  String getStringDate(DateTime dt) {
    return "${dt.year}/${dt.month}/${dt.day}";
  }

  @override
  Widget build(BuildContext context) {
    return _getDashboard();
  }

  Widget _getDashboard() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddExpense(
                          expenseBloc: _expenseBloc,
                          categoryBloc: _categoryBloc,
                        )));
          },
          child: const Icon(Icons.add)),
      body: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(12.0),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MaterialButton(
                      child: Container(
                        child: _selectedDate == null
                            ? Text('Select a date')
                            : Text(_selectedDate),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Text('Date picker'),
                                  content: Container(
                                    height: 350,
                                    child: Column(
                                      children: <Widget>[
                                        getDateRangePicker(),
                                        MaterialButton(
                                          child: Text("OK"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    ),
                                  ));
                            });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              )),
          Expanded(
            child: _getExpenses(),
          )
        ],
      ),
    );
  }

  Widget getDateRangePicker() {
    return Container(
        width: 350.0,
        height: 300.0,
        child: Card(
            child: SfDateRangePicker(
          view: DateRangePickerView.month,
          selectionMode: DateRangePickerSelectionMode.single,
          onSelectionChanged: selectionChanged,
        )));
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    _selectedDate = DateFormat('yyyy-MM-dd').format(args.value);
    _expenseBloc.getExpensesByDate(_selectedDate);

    SchedulerBinding.instance.addPostFrameCallback((duration) {
      setState(() {});
    });
  }

  Widget _getExpenses() {
    return Column(
      children: <Widget>[
// Stream builder allows auto update of UI i.e. when items in db list are deleted
//We do not have to update the UI programmatically!
        StreamBuilder(
          stream: _expenseBloc.expenseListSelectDateStream,
          builder: (_, AsyncSnapshot<BuiltList<ExpenseModel>> expenseListSnap) {
            if (!expenseListSnap.hasData) {
              return const CircularProgressIndicator();
            }

            var lsCategories = expenseListSnap.data;

            return Expanded(
              child: ListView.builder(
                itemCount: lsCategories.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  var expense = lsCategories[index];
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(
                            width: 1.0,
                            style: BorderStyle.solid,
                            color: Colors.white)),
                    margin: const EdgeInsets.all(12.0),
                    child: ListTile(
                      onTap: () {},
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Theme.of(context).primaryColorLight,
                        onPressed: () => _expenseBloc.deleteExpense(expense.id),
                      ),
                      title: Text(
                        "${expense.title} - Ugx.${expense.amount}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        expense.notes,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        )
      ],
    );
  }
}
