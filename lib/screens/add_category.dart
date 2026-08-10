import 'package:flutter/material.dart';
import 'package:my_expenses/models/category_model.dart';
import 'package:my_expenses/blocs/category_bloc.dart';

class AddCategory extends StatefulWidget {
  final CategoryBloc categoryBloc;
  final CategoryModel categoryToEdit;

  const AddCategory({Key key, this.categoryBloc, this.categoryToEdit})
      : super(key: key);

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController _titleTextController = TextEditingController();
  TextEditingController _descTextController = TextEditingController();

  bool get _isEditing => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      widget.categoryBloc.updateCreateCategory(widget.categoryToEdit);
      _titleTextController.text = widget.categoryToEdit.title ?? "";
      _descTextController.text = widget.categoryToEdit.desc ?? "";
    } else {
      widget.categoryBloc.updateCreateCategory(CategoryModel());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Category" : "Add New Category"),
      ),
      body: Container(
          padding: EdgeInsets.all(12.0),
          child: StreamBuilder(
            stream: widget.categoryBloc.createCategoryStream,
            builder: (ctxt, AsyncSnapshot<CategoryModel> catgorySnap) {
              if (catgorySnap.hasError) {
                return Text("Something went wrong: ${catgorySnap.error}");
              }
              if (!catgorySnap.hasData) return CircularProgressIndicator();
              return Column(
                children: <Widget>[
                  TextField(
                      controller: _titleTextController,
                      decoration: InputDecoration(labelText: "Title"),
                      onChanged: (String text) {
                        if (text == null || text.trim() == "") return;
                        var category = catgorySnap.data;
                        var upated = category.rebuild((b) => b..title = text);
                        widget.categoryBloc.updateCreateCategory(upated);
                      }),
                  TextField(
                      controller: _descTextController,
                      decoration: InputDecoration(labelText: "Description"),
                      maxLines: 2,
                      onChanged: (String text) {
                        if (text == null || text.trim() == "") return;
                        var category = catgorySnap.data;
                        var upated = category.rebuild((b) => b..desc = text);
                        widget.categoryBloc.updateCreateCategory(upated);
                      }),
                  Container(
                    child: Text("Pick An Icon:"),
                    margin: EdgeInsets.all(12.0),
                  ),
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: _showIconGrid(catgorySnap.data))),
                  ElevatedButton(
                    child: Text(_isEditing ? "Save" : "Create"),
                    onPressed: catgorySnap.data.title == null
                        ? null
                        : () async {
                            try {
                              var resultId = _isEditing
                                  ? await widget.categoryBloc
                                      .saveCategory(catgorySnap.data)
                                  : await widget.categoryBloc
                                      .createNewCategory(catgorySnap.data);
                              if (resultId > 0) {
                                widget.categoryBloc.getCategories();
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(_isEditing
                                            ? "Couldn't save this category"
                                            : "A category with that title already exists")));
                              }
                            } catch (err) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Something went wrong: $err")));
                            }
                          },
                  ),
                ],
              );
            },
          )),
    );
  }

  _showIconGrid(CategoryModel category) {
    var ls = [
      Icons.web_asset,
      Icons.weekend,
      Icons.whatshot,
      Icons.widgets,
      Icons.wifi,
      Icons.wifi_lock,
      Icons.wifi_tethering,
      Icons.work,
      Icons.wrap_text,
      Icons.youtube_searched_for,
      Icons.zoom_in,
      Icons.zoom_out,
      Icons.zoom_out_map,
      Icons.restaurant_menu,
      Icons.restore,
      Icons.restore_from_trash,
      Icons.restore_page,
      Icons.ring_volume,
      Icons.room,
      Icons.exposure_zero,
      Icons.extension,
      Icons.face,
      Icons.fast_forward,
      Icons.fast_rewind,
      Icons.fastfood,
      Icons.favorite,
      Icons.favorite_border,
    ];

    return GridView.count(
      crossAxisCount: 8,
      children: List.generate(ls.length, (index) {
        var iconData = ls[index];
        return IconButton(
            color: category.iconCodePoint == null
                ? null
                : category.iconCodePoint == iconData.codePoint
                    ? Colors.yellowAccent
                    : null,
            onPressed: () {
              var upated = category
                  .rebuild((b) => b..iconCodePoint = iconData.codePoint);
              widget.categoryBloc.updateCreateCategory(upated);
            },
            icon: Icon(
              iconData,
            ));
      }),
    );
  }
}
