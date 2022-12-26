import 'package:built_collection/built_collection.dart';
import 'package:my_expenses/models/category_model.dart';
import 'package:my_expenses/screens/add_category.dart';

import 'package:my_expenses/db/services/category_service.dart';
import 'package:my_expenses/blocs/category_bloc.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  CategoryBloc _categoryBloc;

  @override
  initState() {
    super.initState();
    _categoryBloc = CategoryBloc(CategoryService());
  }

  @override
  Widget build(BuildContext context) {
    return _getCategoryTab();
  }

  Widget _getCategoryTab() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(12.0),
          width: 200.0,
          child: ElevatedButton(
            child: Text("Add New"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddCategory(
                          categoryBloc: _categoryBloc,
                        )),
              );
            },
          ),
        ),
// Stream builder allows auto update of UI i.e. when items in db list are deleted
//We do not have to update the UI programmatically!
        StreamBuilder(
          stream: _categoryBloc.categoryListStream,
          builder:
              (_, AsyncSnapshot<BuiltList<CategoryModel>> categoryListSnap) {
            if (!categoryListSnap.hasData) return CircularProgressIndicator();

            var lsCategories = categoryListSnap.data;

            return Expanded(
              child: ListView.builder(
                itemCount: lsCategories.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  var category = lsCategories[index];
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
                      leading: Icon(
                        IconData(category.iconCodePoint,
                            fontFamily: 'MaterialIcons'),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: Text(
                        category.title,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      subtitle: Text(
                        category.desc,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Theme.of(context).primaryColorLight,
                        onPressed: () =>
                            _categoryBloc.deleteCategory(category.id),
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
