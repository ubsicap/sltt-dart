import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'base_data_fields.g.dart';

/// These fields are shared across entity types in dataJson.
/// See also CoreEntityStateDataFields
@JsonSerializable(includeIfNull: true, checked: true)
class BaseDataFields implements CoreDataFields {
  @override
  String parentId;
  @override
  String parentProp;
  @override
  String? rank;
  @override
  bool? deleted;

  BaseDataFields({
    required this.parentId,
    required this.parentProp,
    this.rank,
    this.deleted,
  });

  factory BaseDataFields.fromJson(Map<String, dynamic> json) =>
      _$BaseDataFieldsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$BaseDataFieldsToJson(this)..removeWhere((key, value) => value == null);
}
