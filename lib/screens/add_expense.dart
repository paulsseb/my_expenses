import 'package:built_collection/built_collection.dart';
import 'package:my_expenses/blocs/category_bloc.dart';
import 'package:my_expenses/db/services/category_service.dart';
import 'package:my_expenses/models/category_model.dart';
import 'package:flutter/material.dart';

class AddExpense extends StatefulWidget {
  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  CategoryBloc categoryBloc;

  @override
  void initState() {
    super.initState();
    categoryBloc = CategoryBloc(CategoryService());
  }

  int selectedCategoryId = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add New Expense"),
        ),
        body: Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    "Pick Category",
                    style: Theme.of(context).textTheme.bodyText1,
                  )),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: StreamBuilder(
                  stream: categoryBloc.categoryListStream,
                  builder: (_, AsyncSnapshot<BuiltList<CategoryModel>> snap) {
                    if (!snap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Wrap(
                        children: List.generate(snap.data.length, (int index) {
                      var categoryModel = snap.data[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                        ),
                        child: ChoiceChip(
                          selectedColor:
                              Theme.of(context).colorScheme.secondary,
                          selected: categoryModel.id == selectedCategoryId,
                          label: Text(categoryModel.title),
                          onSelected: (selected) {
                            setState(() {
                              selectedCategoryId = categoryModel.id;
                            });
                          },
                        ),
                      );
                    }));
                  },
                ),
              )
            ],
          ),
        ));
  }
}
