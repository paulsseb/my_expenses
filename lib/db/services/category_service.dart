import 'package:built_collection/built_collection.dart';
import 'package:my_expenses/models/category_model.dart';

import '../../models/serializers.dart';
import '../offline_db_provider.dart';

abstract class CategoryServiceBase {
  Future<BuiltList<CategoryModel>> getAllCategories();
  Future<int> createCategory(CategoryModel category);
  Future<int> deleteCategory(int categoryId);
}

class CategoryService implements CategoryServiceBase {
  @override
  Future<BuiltList<CategoryModel>> getAllCategories() async {
    var db = await OfflineDbProvider.provider.database;
    var res = await db.query("Category");
    if (res.isEmpty) return BuiltList();

    var list = BuiltList<CategoryModel>();
    for (var cat in res) {
      var category = serializers.deserializeWith<CategoryModel>(
          CategoryModel.serializer, cat);
      list = list.rebuild((b) => b..add(category));
    }

    return list.rebuild((b) => b..sort((a, b) => a.title.compareTo(b.title)));
  }

  @override
  Future<int> createCategory(CategoryModel category) async {
    //check if exists already
    var exists = await categoryExists(category.title);

    if (exists) return 0;

    var db = await OfflineDbProvider.provider.database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id) as id FROM Category");
    int firstid = table.first["id"];
    int id = table.first["id"] == null ? 1 : firstid + 1;
    //insert to the table using the new id
    var resultId = await db.rawInsert(
        "INSERT Into Category (id, title, desc, iconCodePoint)"
        " VALUES (?,?,?,?)",
        [id, category.title, category.desc, category.iconCodePoint.toString()]);
    return resultId;
  }

  Future<bool> categoryExists(String title) async {
    var db = await OfflineDbProvider.provider.database;
    var res = await db.query("Category");
    if (res.isEmpty) return false;

    var entity = res.firstWhere((b) => b["title"] == title, orElse: () => null);

    return entity.isNotEmpty;
  }

  @override
  Future<int> deleteCategory(int categoryId) async {
    var db = await OfflineDbProvider.provider.database;
    var result =
        db.delete("Category", where: "id = ?", whereArgs: [categoryId]);
    return result;
  }
}
