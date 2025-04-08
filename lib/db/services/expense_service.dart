import 'package:built_collection/built_collection.dart';
import 'package:my_expenses/models/expense_model.dart';

import '../../models/serializers.dart';
import '../offline_db_provider.dart';

abstract class ExpenseServiceBase {
  Future<BuiltList<ExpenseModel>> getAllExpenses();
  Future<int> createExpense(ExpenseModel expense);
  Future<int> deleteExpense(int expenseId);
}

class ExpenseService implements ExpenseServiceBase {
  @override
  Future<BuiltList<ExpenseModel>> getAllExpenses() async {
    var db = await OfflineDbProvider.provider.database;
    var res = await db.query("Expense");
    if (res.isEmpty) return BuiltList();

    var list = BuiltList<ExpenseModel>();
    for (var cat in res) {
      var expense = serializers.deserializeWith<ExpenseModel>(
          ExpenseModel.serializer, cat);
      list = list.rebuild((b) => b..add(expense));
    }

    return list.rebuild((b) => b..sort((a, b) => a.title.compareTo(b.title)));
  }

  @override
  Future<int> createExpense(ExpenseModel expense) async {
    //check if exists already
    // var exists = await expenseExists(expense.title);
    // if (exists) return 0;

    var db = await OfflineDbProvider.provider.database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id) as id FROM Expense");
    int firstid = table.first["id"];
    int id = table.first["id"] == null ? 1 : firstid + 1;
    //insert to the table using the new id
    var resultId = await db.rawInsert(
        "INSERT Into Expense (id, categoryId, title, notes, amount)"
        " VALUES (?,?,?,?,?)",
        [id, expense.categoryId, expense.title, expense.notes, expense.amount]);
    //expense.notes.toString(),
    return resultId;
  }

  Future<bool> expenseExists(String title) async {
    var db = await OfflineDbProvider.provider.database;
    var res = await db.query("Expense");
    if (res.isEmpty) return false;

    var entity = res.firstWhere((b) => b["title"] == title, orElse: () => null);

    return entity.isNotEmpty;
  }

  @override
  Future<int> deleteExpense(int expenseId) async {
    var db = await OfflineDbProvider.provider.database;
    var result = db.delete("Expense", where: "id = ?", whereArgs: [expenseId]);
    return result;
  }
}
