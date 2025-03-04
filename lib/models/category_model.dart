import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'category_model.g.dart';

abstract class CategoryModel
    implements Built<CategoryModel, CategoryModelBuilder> {
  CategoryModel._();
  factory CategoryModel([void Function(CategoryModelBuilder) updates]) =
      _$CategoryModel;

  static Serializer<CategoryModel> get serializer => _$categoryModelSerializer;

  @nullable
  int? get id;
  @nullable
  String? get title;
  @nullable
  String? get desc;
  @nullable
  int? get iconCodePoint;
}
