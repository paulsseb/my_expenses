import 'package:my_expenses/models/category_model.dart';
import 'package:my_expenses/screens/add_category.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<CategoryModel> _lsCateogies = <CategoryModel>[];

  @override
  initState() {
    super.initState();
    _initCategories();
  }

  _initCategories() {
    var cat1 = CategoryModel().rebuild((b) => b
      ..id = 0
      ..title = "Home Utils"
      ..desc = "Home utility related expenses"
      ..iconCodePoint = Icons.home.codePoint);

    _lsCateogies.add(cat1);

    var cat2 = CategoryModel().rebuild((b) => b
      ..id = 0
      ..title = "Grocery"
      ..desc = "Grocery related expenses"
      ..iconCodePoint = Icons.local_grocery_store.codePoint);

    _lsCateogies.add(cat2);

    var cat3 = CategoryModel().rebuild((b) => b
      ..id = 0
      ..title = "Food"
      ..desc = "Food related expenses"
      ..iconCodePoint = Icons.fastfood.codePoint);

    _lsCateogies.add(cat3);

    var cat4 = CategoryModel().rebuild((b) => b
      ..id = 0
      ..title = "Auto"
      ..desc = "Car/Bike related expenses"
      ..iconCodePoint = Icons.directions_bike.codePoint);

    _lsCateogies.add(cat4);
  }

  @override
  Widget build(BuildContext context) {
    return _getCategoryTab();
  }

  Widget _getCategoryTab() {
    return Column(children: <Widget>[
      Container(
        padding: const EdgeInsets.all(12.0),
        width: 200.0,
        child: ElevatedButton(
          child: const Text("Add New"),
          onPressed: () {
            //todo: implement navigation
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCategory()),
            );
          },
        ),
      ),
      Expanded(
          child: ListView.builder(
        itemCount: _lsCateogies.length,
        itemBuilder: (BuildContext ctxt, int index) {
          var category = _lsCateogies[index];
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                    width: 1.0, style: BorderStyle.solid, color: Colors.white)),
            margin: const EdgeInsets.all(12.0),
            child: ListTile(
              onTap: () {},
              leading: Icon(
                IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: Theme.of(context).secondaryHeaderColor,
              ),
              title: Text(
                category.title,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              subtitle: Text(
                category.desc,
              ),
            ),
          );
        },
      )),
    ]);
  }
}
