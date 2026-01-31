// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteData _$NoteDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NoteData', json, ($checkedConvert) {
      final val = NoteData(
        title: $checkedConvert('title', (v) => v as String),
        videoCommentId: $checkedConvert('videoCommentId', (v) => v as String?),
        textComment: $checkedConvert('textComment', (v) => v as String?),
        markerColorValue: $checkedConvert(
          'markerColorValue',
          (v) => (v as num).toInt(),
        ),
        markerShape: $checkedConvert('markerShape', (v) => v as String),
        markerDescription: $checkedConvert(
          'markerDescription',
          (v) => v as String,
        ),
        positionMs: $checkedConvert('positionMs', (v) => (v as num).toInt()),
        resolution: $checkedConvert('resolution', (v) => v as String),
        parentId: $checkedConvert('parentId', (v) => v as String),
        parentProp: $checkedConvert('parentProp', (v) => v as String),
        rank: $checkedConvert('rank', (v) => v as String?),
      );
      $checkedConvert('deleted', (v) => val.deleted = v as bool?);
      return val;
    });

Map<String, dynamic> _$NoteDataToJson(NoteData instance) => <String, dynamic>{
  'parentId': instance.parentId,
  'parentProp': instance.parentProp,
  'rank': ?instance.rank,
  'deleted': ?instance.deleted,
  'title': instance.title,
  'videoCommentId': ?instance.videoCommentId,
  'textComment': ?instance.textComment,
  'markerColorValue': instance.markerColorValue,
  'markerShape': instance.markerShape,
  'markerDescription': instance.markerDescription,
  'positionMs': instance.positionMs,
  'resolution': instance.resolution,
};
