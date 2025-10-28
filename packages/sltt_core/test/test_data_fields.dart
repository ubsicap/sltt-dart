import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'test_data_fields.g.dart';

/// Data fields for test entities.
/// Extends BaseDataFields with test-specific fields like nameLocal and nameOptionalField.
@JsonSerializable(includeIfNull: true, checked: true)
class TestDataFields extends BaseDataFields {
  String nameLocal;
  String? nameOptionalField;

  TestDataFields({
    required this.nameLocal,
    required super.parentId,
    required super.parentProp,
    super.rank,
    super.deleted,
    this.nameOptionalField,
  });

  factory TestDataFields.fromJson(Map<String, dynamic> json) =>
      _$TestDataFieldsFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$TestDataFieldsToJson(this)..removeWhere((key, value) => value == null);
}
