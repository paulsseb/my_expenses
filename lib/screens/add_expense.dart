import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import 'package:my_expenses/db/services/expense_service.dart';
import 'package:my_expenses/blocs/expense_bloc.dart';
import 'package:my_expenses/models/expense_model.dart';

import 'package:my_expenses/db/services/category_service.dart';
import 'package:my_expenses/models/category_model.dart';
import 'package:my_expenses/blocs/category_bloc.dart';

class AddExpense extends StatefulWidget {
  final ExpenseBloc expenseBloc;
  final CategoryBloc categoryBloc;
  const AddExpense({Key key, this.expenseBloc, this.categoryBloc})
      : super(key: key);

  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  FocusNode _focus = new FocusNode();
  bool _showKeyboard = false;
  TextEditingController _amountTextController = TextEditingController();
  CategoryBloc categoryBloc;
  // ExpenseBloc expenseBloc;

  @override
  void initState() {
    super.initState();
    widget.expenseBloc.updateCreateExpense(ExpenseModel());
    widget.categoryBloc.updateCreateCategory(CategoryModel());
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _showKeyboard = _focus.hasFocus;
    });
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
                  stream: widget.categoryBloc.categoryListStream,
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
              ),
              Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(12.0),
                      child: StreamBuilder(
                        stream: widget.expenseBloc.createExpenseStream,
                        builder:
                            (ctxt, AsyncSnapshot<ExpenseModel> expenseSnap) {
                          if (!expenseSnap.hasData)
                            return CircularProgressIndicator();
                          return Column(
                            children: <Widget>[
                              TextField(
                                  controller: _amountTextController,
                                  focusNode: _focus,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Amount",
                                  ),
                                  maxLines: 1,
                                  onChanged: (String text) {
                                    if (text == null || text.trim() == "")
                                      return;
                                    var category = expenseSnap.data;
                                    var upated = category.rebuild(
                                        (b) => b..amount = double.parse(text));
                                    widget.expenseBloc
                                        .updateCreateExpense(upated);
                                  }),
                              TextField(
                                  decoration:
                                      InputDecoration(labelText: "Title"),
                                  onChanged: (String text) {
                                    if (text == null || text.trim() == "")
                                      return;
                                    var category = expenseSnap.data;
                                    var upated = category
                                        .rebuild((b) => b..title = text);
                                    widget.expenseBloc
                                        .updateCreateExpense(upated);
                                  }),
                              TextField(
                                  decoration:
                                      InputDecoration(labelText: "Notes"),
                                  maxLines: 2,
                                  onChanged: (String text) {
                                    if (text == null || text.trim() == "")
                                      return;
                                    var expense = expenseSnap.data;
                                    var upated =
                                        expense.rebuild((b) => b..notes = text);
                                    widget.expenseBloc
                                        .updateCreateExpense(upated);
                                  }),
                              ElevatedButton(
                                child: Text("Create"),
                                onPressed: expenseSnap.data.title == null
                                    ? null
                                    : () async {
                                        var createdId = await widget.expenseBloc
                                            .createNewExpense(expenseSnap.data);
                                        if (createdId > 0) {
                                          Navigator.of(context).pop();
                                          widget.expenseBloc.getExpenses();
                                        } else {
                                          //show error here...
                                        }
                                      },
                              ),
                            ],
                          );
                        },
                      )),
                  _shortcutKeyboard(),
                ],
              )
            ],
          ),
        ));
  }

  Widget _shortcutKeyboard() {
    var keyboardKeys = [
      "50",
      "100",
      "500",
      "1000",
    ];
    return Container(
        height: 53.0,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: keyboardKeys.length,
          itemBuilder: (_, index) {
            var key = keyboardKeys[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                  )),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _amountTextController.value =
                        _amountTextController.value.copyWith(
                      text: key,
                      selection: TextSelection.collapsed(offset: key.length),
                    );
                  });
                },
                child: Text(key),
              ),
            );
          },
        ));
  }
}
