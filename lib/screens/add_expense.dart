import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
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
  DateTime date = DateTime.now();

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
                          if (!expenseSnap.hasData) {
                            return const CircularProgressIndicator();
                          }
                          return Column(
                            children: <Widget>[
                              _DatePickerItem(
                                children: <Widget>[
                                  const Text('Date'),
                                  CupertinoButton(
                                    // Display a CupertinoDatePicker in date picker mode.
                                    onPressed: () => _showDialog(
                                      CupertinoDatePicker(
                                        initialDateTime: date,
                                        mode: CupertinoDatePickerMode.date,
                                        use24hFormat: true,
                                        // This is called when the user changes the date.
                                        onDateTimeChanged: (DateTime newDate) {
                                          setState(() => date = newDate);
                                          if (newDate == null) return;
                                          var notes = expenseSnap.data;
                                          // wip .. date attrib to be added
                                          var upated = notes.rebuild((b) => b
                                            ..notes =
                                                '${date.month}-${date.day}-${date.year}');
                                          widget.expenseBloc
                                              .updateCreateExpense(upated);
                                        },
                                      ),
                                    ),
                                    // In this example, the date is formatted manually. You can
                                    // use the intl package to format the value based on the
                                    // user's locale settings.
                                    child: Text(
                                      '${date.month}-${date.day}-${date.year}',
                                      style: const TextStyle(
                                        fontSize: 22.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                    var amount = expenseSnap.data;
                                    var upated = amount.rebuild(
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
                                    var title = expenseSnap.data;
                                    var upated =
                                        title.rebuild((b) => b..title = text);
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
                                    var notes = expenseSnap.data;
                                    var upated =
                                        notes.rebuild((b) => b..notes = text);
                                    widget.expenseBloc
                                        .updateCreateExpense(upated);
                                  }),
                              ElevatedButton(
                                child: Text("Create"),
                                onPressed: expenseSnap.data.title == null
                                    ? null
                                    : () async {
                                        var expnseCat = expenseSnap.data;
                                        var upated = expnseCat.rebuild((b) =>
                                            b..categoryId = selectedCategoryId);
                                        await widget.expenseBloc
                                            .updateCreateExpense(upated);

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

  // This function displays a CupertinoModalPopup with a reasonable fixed height
  // which hosts CupertinoDatePicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 500,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system
              // navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }
}

// This class simply decorates a row of widgets.
class _DatePickerItem extends StatelessWidget {
  const _DatePickerItem({this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoColors.inactiveGray,
            width: 0.0,
          ),
          bottom: BorderSide(
            color: CupertinoColors.inactiveGray,
            width: 0.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}
