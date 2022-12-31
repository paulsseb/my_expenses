import 'package:my_expenses/db/services/expense_service.dart';
import 'package:my_expenses/models/expense_model.dart';

import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:rxdart/rxdart.dart';

class ExpenseBloc {
  final ExpenseServiceBase expenseService;

  ExpenseBloc(this.expenseService) {
    getExpenses();
  }

  final _createExpenseController = BehaviorSubject<ExpenseModel>();
  Stream<ExpenseModel> get createExpenseStream =>
      _createExpenseController.stream;

  updateCreateExpense(ExpenseModel exp) =>
      _createExpenseController.sink.add(exp);

  final _expenseListController = BehaviorSubject<BuiltList<ExpenseModel>>();
  Stream<BuiltList<ExpenseModel>> get expenseListStream =>
      _expenseListController.stream;

  getExpenses() {
    expenseService.getAllExpenses().then((exp) {
      _expenseListController.sink.add(exp);
    }).catchError((err) {
      _expenseListController.sink.addError(err);
    });
  }

  Future<int> createNewExpense(ExpenseModel expense) async {
    return await expenseService.createExpense(expense);
  }

  dispose() {
    _createExpenseController.close();
    _expenseListController.close();
  }

  Future<void> deleteExpense(int expenseId) async {
    await expenseService.deleteExpense(expenseId).then((value) {
      //re- create list after delete
      getExpenses();
    });
  }
}
