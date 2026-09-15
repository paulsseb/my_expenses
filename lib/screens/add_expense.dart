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
import 'package:my_expenses/utils/currency.dart';

class AddExpense extends StatefulWidget {
  final ExpenseBloc expenseBloc;
  final CategoryBloc categoryBloc;
  final ExpenseModel? expenseToEdit;
  const AddExpense(
      {Key? key,
      required this.expenseBloc,
      required this.categoryBloc,
      this.expenseToEdit})
      : super(key: key);

  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final FocusNode _focus = FocusNode();
  bool _showKeyboard = false;
  final TextEditingController _amountTextController = TextEditingController();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _notesTextController = TextEditingController();
  AsyncSnapshot<ExpenseModel>? expenseSnap;

  bool get _isEditing => widget.expenseToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final editing = widget.expenseToEdit!;
      widget.expenseBloc.updateCreateExpense(editing);
      selectedCategoryId = editing.categoryId ?? 0;
      _selectedDate =
          editing.date == null ? DateTime.now() : DateTime.parse(editing.date!);
      _amountTextController.text =
          editing.amount == null ? "" : formatAmount(editing.amount);
      _titleTextController.text = editing.title ?? "";
      _notesTextController.text = editing.notes ?? "";
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

  void _onAmountChanged(String text, ExpenseModel expense) {
    var parsedAmount = parseAmount(text);
    if (parsedAmount == null) return;
    widget.expenseBloc
        .updateCreateExpense(expense.rebuild((b) => b..amount = parsedAmount));
  }

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
                    style: Theme.of(context).textTheme.bodyLarge,
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
                        children:
                            List.generate(snap.data!.length, (int index) {
                      var categoryModel = snap.data![index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                        ),
                        child: ChoiceChip(
                          selectedColor:
                              Theme.of(context).colorScheme.secondary,
                          selected: categoryModel.id == selectedCategoryId,
                          label: Text(categoryModel.title ?? ""),
                          onSelected: (selected) {
                            setState(() {
                              selectedCategoryId = categoryModel.id ?? 0;
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
                      padding: const EdgeInsets.all(12.0),
                      child: StreamBuilder(
                        stream: widget.expenseBloc.createExpenseStream,
                        builder:
                            (ctxt, AsyncSnapshot<ExpenseModel> expenseSnap2) {
                          expenseSnap = expenseSnap2;
                          if (expenseSnap2.hasError) {
                            return Text(
                                "Something went wrong: ${expenseSnap2.error}");
                          }
                          if (!expenseSnap2.hasData) {
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
                                                title: const Text('Date picker'),
                                                content: SizedBox(
                                                  height: 350,
                                                  child: Column(
                                                    children: <Widget>[
                                                      getDateRangePicker(),
                                                      MaterialButton(
                                                        child: const Text("OK"),
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
                                  inputFormatters: const [
                                    ThousandsSeparatorInputFormatter()
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: "Amount",
                                    prefixText: "$currencySymbol ",
                                  ),
                                  maxLines: 1,
                                  onChanged: (String text) =>
                                      _onAmountChanged(text, expenseSnap2.data!)),
                              TextField(
                                  controller: _titleTextController,
                                  decoration:
                                      const InputDecoration(labelText: "Title"),
                                  onChanged: (String text) {
                                    if (text.trim() == "") return;
                                    var title = expenseSnap2.data!;
                                    var upated =
                                        title.rebuild((b) => b..title = text);
                                    widget.expenseBloc
                                        .updateCreateExpense(upated);
                                  }),
                              TextField(
                                  controller: _notesTextController,
                                  decoration:
                                      const InputDecoration(labelText: "Notes"),
                                  maxLines: 2,
                                  onChanged: (String text) {
                                    if (text.trim() == "") return;
                                    var notes = expenseSnap2.data!;
                                    var upated =
                                        notes.rebuild((b) => b..notes = text);
                                    widget.expenseBloc
                                        .updateCreateExpense(upated);
                                  }),
                              ElevatedButton(
                                onPressed: expenseSnap2.data!.title == null
                                    ? null
                                    : () async {
                                        var expnseCat = expenseSnap2.data!;
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
                                child: Text(_isEditing ? "Save" : "Create"),
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
    return SizedBox(
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
    var date = expenseSnap!.data!;
    var upated = date.rebuild(
        (b) => b..date = DateFormat('yyyy-MM-dd').format(_selectedDate));
    widget.expenseBloc.updateCreateExpense(upated);

    SchedulerBinding.instance.addPostFrameCallback((duration) {
      setState(() {});
    });
  }

  Widget _shortcutKeyboard() {
    var keyboardKeys = [50, 100, 500, 1000];
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
            var label = formatAmount(key);
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
                      text: label,
                      selection: TextSelection.collapsed(offset: label.length),
                    );
                  });
                  var expense = expenseSnap?.data;
                  if (expense != null) _onAmountChanged(label, expense);
                },
                child: Text(label),
              ),
            );
          },
        ));
  }

}

// This class simply decorates a row of widgets.
class _DatePickerItem extends StatelessWidget {
  const _DatePickerItem({required this.children});

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
