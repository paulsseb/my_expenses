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
  final ExpenseModel expenseToEdit;
  const AddExpense(
      {Key key, this.expenseBloc, this.categoryBloc, this.expenseToEdit})
      : super(key: key);

  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  FocusNode _focus = new FocusNode();
  bool _showKeyboard = false;
  TextEditingController _amountTextController = TextEditingController();
  TextEditingController _titleTextController = TextEditingController();
  TextEditingController _notesTextController = TextEditingController();
  AsyncSnapshot<ExpenseModel> expenseSnap;

  bool get _isEditing => widget.expenseToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      widget.expenseBloc.updateCreateExpense(widget.expenseToEdit);
      selectedCategoryId = widget.expenseToEdit.categoryId ?? 0;
      _selectedDate = widget.expenseToEdit.date == null
          ? DateTime.now()
          : DateTime.parse(widget.expenseToEdit.date);
      _amountTextController.text = widget.expenseToEdit.amount == null
          ? ""
          : widget.expenseToEdit.amount.toString();
      _titleTextController.text = widget.expenseToEdit.title ?? "";
      _notesTextController.text = widget.expenseToEdit.notes ?? "";
    } else {
      widget.expenseBloc.updateCreateExpense(
          ExpenseModel((b) => b..date = DateFormat('yyyy-MM-dd').format(_selectedDate)));
    }
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
          title: Text(_isEditing ? "Edit Expense" : "Add New Expense"),
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
                    if (snap.hasError) {
                      return Center(
                        child: Text("Couldn't load categories: ${snap.error}"),
                      );
                    }
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
                          if (expenseSnap.hasError) {
                            return Text(
                                "Something went wrong: ${expenseSnap.error}");
                          }
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
                                      child: Text(DateFormat('yyyy-MM-dd')
                                          .format(_selectedDate)),
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
                                    var parsedAmount = double.tryParse(text);
                                    if (parsedAmount == null) return;
                                    var amount = expenseSnap.data;
                                    var upated = amount
                                        .rebuild((b) => b..amount = parsedAmount);
                                    widget.expenseBloc
                                        .updateCreateExpense(upated);
                                  }),
                              TextField(
                                  controller: _titleTextController,
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
                                  controller: _notesTextController,
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
                                child: Text(_isEditing ? "Save" : "Create"),
                                onPressed: expenseSnap.data.title == null
                                    ? null
                                    : () async {
                                        var expnseCat = expenseSnap.data;
                                        var upated = expnseCat.rebuild((b) =>
                                            b..categoryId = selectedCategoryId);
                                        await widget.expenseBloc
                                            .updateCreateExpense(upated);

                                        try {
                                          var resultId = _isEditing
                                              ? await widget.expenseBloc
                                                  .saveExpense(upated)
                                              : await widget.expenseBloc
                                                  .createNewExpense(upated);
                                          if (resultId > 0) {
                                            widget.expenseBloc.getExpenses();
                                            Navigator.of(context)
                                                .pop(upated.date);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(_isEditing
                                                        ? "Couldn't save this expense"
                                                        : "An expense with that title already exists")));
                                          }
                                        } catch (err) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Something went wrong: $err")));
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
    if (args.value == null) {
      _selectedDate = DateTime.now();
    }
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
