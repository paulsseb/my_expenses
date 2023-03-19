// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ExpenseModel> _$expenseModelSerializer =
    new _$ExpenseModelSerializer();

class _$ExpenseModelSerializer implements StructuredSerializer<ExpenseModel> {
  @override
  final Iterable<Type> types = const [ExpenseModel, _$ExpenseModel];
  @override
  final String wireName = 'ExpenseModel';

  @override
  Iterable<Object> serialize(Serializers serializers, ExpenseModel object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[];
    Object value;
    value = object.id;
    if (value != null) {
      result
        ..add('id')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.categoryId;
    if (value != null) {
      result
        ..add('categoryId')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.title;
    if (value != null) {
      result
        ..add('title')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.notes;
    if (value != null) {
      result
        ..add('notes')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.amount;
    if (value != null) {
      result
        ..add('amount')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.date;
    if (value != null) {
      result
        ..add('date')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  ExpenseModel deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ExpenseModelBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'categoryId':
          result.categoryId = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'notes':
          result.notes = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'amount':
          result.amount = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'date':
          result.date = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$ExpenseModel extends ExpenseModel {
  @override
  final int id;
  @override
  final int categoryId;
  @override
  final String title;
  @override
  final String notes;
  @override
  final double amount;
  @override
  final String date;

  factory _$ExpenseModel([void Function(ExpenseModelBuilder) updates]) =>
      (new ExpenseModelBuilder()..update(updates))._build();

  _$ExpenseModel._(
      {this.id,
      this.categoryId,
      this.title,
      this.notes,
      this.amount,
      this.date})
      : super._();

  @override
  ExpenseModel rebuild(void Function(ExpenseModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExpenseModelBuilder toBuilder() => new ExpenseModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExpenseModel &&
        id == other.id &&
        categoryId == other.categoryId &&
        title == other.title &&
        notes == other.notes &&
        amount == other.amount &&
        date == other.date;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, categoryId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExpenseModel')
          ..add('id', id)
          ..add('categoryId', categoryId)
          ..add('title', title)
          ..add('notes', notes)
          ..add('amount', amount)
          ..add('date', date))
        .toString();
  }
}

class ExpenseModelBuilder
    implements Builder<ExpenseModel, ExpenseModelBuilder> {
  _$ExpenseModel _$v;

  int _id;
  int get id => _$this._id;
  set id(int id) => _$this._id = id;

  int _categoryId;
  int get categoryId => _$this._categoryId;
  set categoryId(int categoryId) => _$this._categoryId = categoryId;

  String _title;
  String get title => _$this._title;
  set title(String title) => _$this._title = title;

  String _notes;
  String get notes => _$this._notes;
  set notes(String notes) => _$this._notes = notes;

  double _amount;
  double get amount => _$this._amount;
  set amount(double amount) => _$this._amount = amount;

  String _date;
  String get date => _$this._date;
  set date(String date) => _$this._date = date;

  ExpenseModelBuilder();

  ExpenseModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _categoryId = $v.categoryId;
      _title = $v.title;
      _notes = $v.notes;
      _amount = $v.amount;
      _date = $v.date;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExpenseModel other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ExpenseModel;
  }

  @override
  void update(void Function(ExpenseModelBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  ExpenseModel build() => _build();

  _$ExpenseModel _build() {
    final _$result = _$v ??
        new _$ExpenseModel._(
            id: id,
            categoryId: categoryId,
            title: title,
            notes: notes,
            amount: amount,
            date: date);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
