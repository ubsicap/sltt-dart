import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'marker.data.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
class MarkerData extends BaseDataFields {
  /// Marker color stored as ARGB int.
  final int colorValue;
  final String shape;
  final String description;

  MarkerData({
    required this.colorValue,
    required this.shape,
    required this.description,
    required super.parentId,
    required super.parentProp,
    required super.rank,
    super.deleted,
  });

  factory MarkerData.fromJson(Map<String, dynamic> json) =>
      _$MarkerDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MarkerDataToJson(this);
}
