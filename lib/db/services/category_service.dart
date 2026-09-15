import 'package:built_collection/built_collection.dart';
import 'package:my_expenses/models/category_model.dart';

import '../../models/serializers.dart';
import '../offline_db_provider.dart';

abstract class CategoryServiceBase {
  Future<BuiltList<CategoryModel>> getAllCategories();
  Future<int> createCategory(CategoryModel category);
  Future<int> updateCategory(CategoryModel category);
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
          CategoryModel.serializer, cat)!;
      list = list.rebuild((b) => b..add(category));
    }

    return list.rebuild(
        (b) => b..sort((a, b) => (a.title ?? "").compareTo(b.title ?? "")));
  }

  @override
  Future<int> createCategory(CategoryModel category) async {
    var exists = await categoryExists(category.title ?? "");
    if (exists) return 0;

    var db = await OfflineDbProvider.provider.database;
    return await db.insert("Category", {
      "title": category.title,
      "desc": category.desc,
      "iconCodePoint": category.iconCodePoint,
    });
  }

  @override
  Future<int> updateCategory(CategoryModel category) async {
    var db = await OfflineDbProvider.provider.database;
    return await db.update(
        "Category",
        {
          "title": category.title,
          "desc": category.desc,
          "iconCodePoint": category.iconCodePoint,
        },
        where: "id = ?",
        whereArgs: [category.id]);
  }

  Future<bool> categoryExists(String title) async {
    var db = await OfflineDbProvider.provider.database;
    var res = await db.query("Category");
    if (res.isEmpty) return false;

    for (var entity in res) {
      if (entity["title"] == title) return entity.isNotEmpty;
    }
    return false;
  }

  @override
  Future<int> deleteCategory(int categoryId) async {
    var db = await OfflineDbProvider.provider.database;
    var result =
        db.delete("Category", where: "id = ?", whereArgs: [categoryId]);
    return result;
  }
}
