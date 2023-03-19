import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

import 'package:my_expenses/blocs/expense_bloc.dart';
import 'package:my_expenses/models/expense_model.dart';

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
  AsyncSnapshot<ExpenseModel> expenseSnap;
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
  DateTime _selectedDate = DateTime.now();

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
                            (ctxt, AsyncSnapshot<ExpenseModel> expenseSnap2) {
                          expenseSnap = expenseSnap2;
                          if (!expenseSnap.hasData) {
                            return const CircularProgressIndicator();
                          }
                          return Column(
                            children: <Widget>[
                              _DatePickerItem(
                                children: <Widget>[
                                  const Text('Date'),
                                  MaterialButton(
                                    child: Container(
                                      child: _selectedDate == null
                                          ? Text('Select a date')
                                          : Text(
                                              '${_selectedDate.month}-${_selectedDate.day}-${_selectedDate.year}'),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                                title: Text('Date picker'),
                                                content: Container(
                                                  height: 350,
                                                  child: Column(
                                                    children: <Widget>[
                                                      getDateRangePicker(),
                                                      MaterialButton(
                                                        child: Text("OK"),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ));
                                          });
                                    },
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

  Widget getDateRangePicker() {
    return Container(
        width: 350.0,
        height: 300.0,
        child: Card(
            child: SfDateRangePicker(
          view: DateRangePickerView.month,
          selectionMode: DateRangePickerSelectionMode.single,
          onSelectionChanged: selectionChanged,
        )));
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() => _selectedDate = args.value);
    if (args.value == null) return;
    var date = expenseSnap.data;
    var upated = date.rebuild(
        (b) => b..date = DateFormat('yyyy-MM-dd').format(_selectedDate));
    widget.expenseBloc.updateCreateExpense(upated);

    SchedulerBinding.instance.addPostFrameCallback((duration) {
      setState(() {});
    });
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
