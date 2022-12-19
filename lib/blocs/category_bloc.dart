import 'package:my_expenses/db/services/category_service.dart';
import 'package:my_expenses/models/category_model.dart';

class CategoryBloc {
  final CategoryServiceBase categoryService;
  CategoryBloc(this.categoryService) {}

// controller that will be used to manage Category stream.
  var _createCategoryController = BehaviorSubject<CategoryModel>();
  Stream<CategoryModel> get createCategoryStream =>
      _createCategoryController.stream;

  updateCreateCategory(CategoryModel cat) =>
      _createCategoryController.sink.add(cat);
}
