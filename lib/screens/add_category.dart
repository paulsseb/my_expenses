import 'package:flutter/material.dart';
import 'package:my_expenses/models/category_model.dart';
import 'package:my_expenses/blocs/category_bloc.dart';

class AddCategory extends StatefulWidget {
  final CategoryBloc categoryBloc;

  const AddCategory({super.key, required this.categoryBloc});

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  @override
  void initState() {
    super.initState();
    widget.categoryBloc.updateCreateCategory(CategoryModel());
  }

  @override
  void dispose() {
    widget.categoryBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Category"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<CategoryModel>(
          stream: widget.categoryBloc.createCategoryStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final category = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: "Title"),
                  onChanged: (text) {
                    if (text.trim().isEmpty) return;

                    var updated = category.rebuild((b) => b..title = text); // Use correct property name
                    widget.categoryBloc.updateCreateCategory(updated);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 2,
                  onChanged: (text) {
                    if (text.trim().isEmpty) return;

                    var updated = category.rebuild((b) => b..desc = text); // Use correct property name
                    widget.categoryBloc.updateCreateCategory(updated);
                  },
                ),
                const SizedBox(height: 12),
                const Text("Pick An Icon:"),
                const SizedBox(height: 12),
                Expanded(child: _showIconGrid(category)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: category.title == null || category.title!.isEmpty
                      ? null
                      : () async {
                          int createdId = await widget.categoryBloc
                              .createNewCategory(category);
                          if (createdId > 0) {
                            Navigator.of(context).pop();
                            widget.categoryBloc.getCategories();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error creating category"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: const Text("Create"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _showIconGrid(CategoryModel category) {
    final icons = [
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

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        var iconData = icons[index];
        return IconButton(
          color: category.iconCodePoint == iconData.codePoint
              ? Colors.yellowAccent
              : null,
          onPressed: () {

            var updated = category.rebuild((b) => b..iconCodePoint = iconData.codePoint); // Use correct property name
            widget.categoryBloc.updateCreateCategory(updated);
            
          },
          icon: Icon(iconData),
        );
      },
    );
  }
}
