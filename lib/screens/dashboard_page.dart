import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  initState() {
    super.initState();
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
                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      getStringDate(DateTime.now()),
                      style: Theme.of(context).textTheme.bodyText1,
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

  Widget _getExpenses() {
    var expense1 = ExpenseModel().rebuild((b) => b
      ..id = 1
      ..title = "Coffee"
      ..notes = "Coffee at peepalbot"
      ..amount = 129.00);

    var expense2 = ExpenseModel().rebuild((b) => b
      ..id = 2
      ..title = "Lunch"
      ..notes = "Momos at dilli bazar"
      ..amount = 150.00);

    var expense3 = ExpenseModel().rebuild((b) => b
      ..id = 3
      ..title = "Pants"
      ..notes = "Bought a pair of pants from Dbmg"
      ..amount = 2500.00);

    var ls = [expense1, expense2, expense3];

    return Column(
      children: <Widget>[
// Stream builder allows auto update of UI i.e. when items in db list are deleted
//We do not have to update the UI programmatically!
        StreamBuilder(
          stream: _expenseBloc.expenseListStream,
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
                        expense.title + " - Ugx." + expense.amount.toString(),
                        style: Theme.of(context).textTheme.bodyText1,
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
