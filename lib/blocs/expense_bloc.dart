import 'package:my_expenses/db/services/expense_service.dart';
import 'package:my_expenses/models/expense_model.dart';

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:built_collection/built_collection.dart';
import 'package:rxdart/rxdart.dart';

class ExpenseBloc {
  final ExpenseServiceBase expenseService;

  ExpenseBloc(this.expenseService) {
    getExpensesByDate(null);
  }

  final _createExpenseController = BehaviorSubject<ExpenseModel>();
  Stream<ExpenseModel> get createExpenseStream =>
      _createExpenseController.stream;

  updateCreateExpense(ExpenseModel exp) =>
      _createExpenseController.sink.add(exp);

  final _expenseListController = BehaviorSubject<BuiltList<ExpenseModel>>();
  Stream<BuiltList<ExpenseModel>> get expenseListStream =>
      _expenseListController.stream;

  final _expenseListSelectDateController =
      BehaviorSubject<BuiltList<ExpenseModel>>();
  Stream<BuiltList<ExpenseModel>> get expenseListSelectDateStream =>
      _expenseListSelectDateController.stream;

  getExpenses() {
    expenseService.getAllExpenses().then((exp) {
      _expenseListController.sink.add(exp);
    }).catchError((err) {
      _expenseListController.sink.addError(err);
    });
  }

  getExpensesByDate(String selectedDate) {
    String pursedate = selectedDate;
    if (selectedDate == null) {
      pursedate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    expenseService.getExpensesByDate(pursedate).then((exp) {
      _expenseListSelectDateController.sink.add(exp);
    }).catchError((err) {
      _expenseListSelectDateController.sink.addError(err);
    });
  }

  Future<int> createNewExpense(ExpenseModel expense) async {
    return await expenseService.createExpense(expense);
  }

  dispose() {
    _createExpenseController.close();
    _expenseListSelectDateController.close();
    _expenseListController.close();
  }

  Future<void> deleteExpense(int expenseId) async {
    await expenseService.deleteExpense(expenseId).then((value) {
      //re- create list after delete
      getExpensesByDate(null);
    });
  }
}
