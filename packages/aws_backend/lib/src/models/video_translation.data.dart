import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'video_translation.data.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
// @SyncableEntityStateData(entityType: kEntityTypeVideo)
class VideoTranslationData extends BaseDataFields {
  final String name;
  final List<String> visibility;
  final String storedFilename;

  VideoTranslationData({
    required this.name,
    required this.visibility,
    required this.storedFilename,
    required super.parentId,
    required super.parentProp,
    required super.rank,
  });

  factory VideoTranslationData.fromJson(Map<String, dynamic> json) =>
      _$VideoTranslationDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VideoTranslationDataToJson(this);
}
