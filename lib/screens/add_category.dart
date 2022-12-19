import 'package:flutter/material.dart';

class AddCategory extends StatefulWidget {
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  CategoryBloc _categoryBloc;

  @override
  void initState() {
    super.initState();
    _categoryBloc = CategoryBloc(CategoryService());
    _categoryBloc.updateCreateCategory(CategoryModel());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Category"),
      ),
      body: Container(
          padding: EdgeInsets.all(12.0),
          child: StreamBuilder(
            stream: _categoryBloc.createCategoryStream,
            builder: (ctxt, AsyncSnapshot<CategoryModel> catgorySnap) {
              //todo:
            },
          )),
    );
  }
}
