import 'package:built_collection/built_collection.dart';
import 'package:my_expenses/models/expense_model.dart';

import '../../models/serializers.dart';
import '../offline_db_provider.dart';

abstract class ExpenseServiceBase {
  Future<BuiltList<ExpenseModel>> getAllExpenses();
  Future<BuiltList<ExpenseModel>> getExpensesByDate(String selectedDate);
  Future<int> createExpense(ExpenseModel expense);
  Future<int> updateExpense(ExpenseModel expense);
  Future<int> deleteExpense(int expenseId);
}

class ExpenseService implements ExpenseServiceBase {
  @override
  Future<BuiltList<ExpenseModel>> getAllExpenses() async {
    var db = await OfflineDbProvider.provider.database;
    var res = await db.query("Expense");
    if (res.isEmpty) return BuiltList();

    var list = BuiltList<ExpenseModel>();
    res.forEach((cat) {
      var expense = serializers.deserializeWith<ExpenseModel>(
          ExpenseModel.serializer, cat);
      list = list.rebuild((b) => b..add(expense));
    });

    return list.rebuild((b) => b..sort((a, b) => a.title.compareTo(b.title)));
  }

  @override
  Future<BuiltList<ExpenseModel>> getExpensesByDate(String selectedDate) async {
    var db = await OfflineDbProvider.provider.database;
    var res = await db
        .rawQuery('SELECT * FROM Expense WHERE date = ?', [selectedDate]);
    if (res.isEmpty) return BuiltList();

    var list = BuiltList<ExpenseModel>();
    res.forEach((cat) {
      var expense = serializers.deserializeWith<ExpenseModel>(
          ExpenseModel.serializer, cat);
      list = list.rebuild((b) => b..add(expense));
    });

    return list.rebuild((b) => b..sort((a, b) => a.title.compareTo(b.title)));
  }

  @override
  Future<int> createExpense(ExpenseModel expense) async {
    var exists = await expenseExists(expense.title);
    if (exists) return 0;

    var db = await OfflineDbProvider.provider.database;
    return await db.insert("Expense", {
      "categoryId": expense.categoryId,
      "title": expense.title,
      "notes": expense.notes,
      "amount": expense.amount,
      "date": expense.date,
    });
  }

  @override
  Future<int> updateExpense(ExpenseModel expense) async {
    var db = await OfflineDbProvider.provider.database;
    return await db.update(
        "Expense",
        {
          "categoryId": expense.categoryId,
          "title": expense.title,
          "notes": expense.notes,
          "amount": expense.amount,
          "date": expense.date,
        },
        where: "id = ?",
        whereArgs: [expense.id]);
  }

  Future<bool> expenseExists(String title) async {
    var db = await OfflineDbProvider.provider.database;
    var res = await db.query("Expense");
    if (res.isEmpty) return false;

    var entity = res.firstWhere((b) => b["title"] == title, orElse: () => null);

    if (entity == null) return false;

    return entity.isNotEmpty;
  }

  @override
  Future<int> deleteExpense(int expenseId) async {
    var db = await OfflineDbProvider.provider.database;
    var result = db.delete("Expense", where: "id = ?", whereArgs: [expenseId]);
    return result;
  }
}
