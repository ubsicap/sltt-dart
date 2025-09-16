import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';

/// Generator that produces `*EntityState` classes for data classes annotated
/// with `@SyncableEntityStateData`.
class SyncableEntityStateDataGenerator extends GeneratorForAnnotation<SyncableEntityStateData> {
  final _formatter = DartFormatter();

  @override
  FutureOr<String?> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) return null;

    final className = element.name;
    final entityStateClassName = '${className}EntityState';
    final entityTypeValue = annotation.read('entityType').stringValue;
    final jsonRequired = annotation.peek('jsonRequired')?.boolValue ?? true;
    final includeIfNull = annotation.peek('includeIfNull')?.boolValue ?? true;
    final enforceIsar = annotation.peek('enforceIsarCompatibility')?.boolValue ?? true;

    // Determine entityType: override or infer from class name (strip 'Data' suffix if present)
    // entityTypeValue already provided explicitly via annotation

    // Collect data fields (instance, non-static, public)
    final allFields = element.fields.where(
      (f) => !f.isStatic && !f.isSynthetic && f.isPublic,
    );
    // Core fields already provided by BaseEntityState; don't generate duplicates.
    // Add 'parentProp' to core fields so generated entity state classes
    // include the base-class parentProp/meta fields rather than generating them.
    const coreFieldNames = {'parentId', 'parentProp', 'deleted', 'rank'};
    final dataFields = allFields.where((f) => !coreFieldNames.contains(f.name));

    // Optionally enforce Isar compatibility
    final incompatible = <String, String>{};
    if (enforceIsar) {
      for (final f in dataFields) {
        final dt = f.type.getDisplayString(withNullability: true);
        if (!_isIsarCompatibleType(f.type)) {
          incompatible[f.name] = dt;
        }
      }
      if (incompatible.isNotEmpty) {
        throw InvalidGenerationSourceError(
          'Fields not Isar-compatible in ${element.name}: ${incompatible.entries.map((e) => '${e.key}:${e.value}').join(', ')}',
          element: element,
        );
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// ignore_for_file: non_constant_identifier_names');
    // original source file name not needed for standalone output
    // Standalone generated file with its own library so json_serializable can generate *_entity_state.g.dart.
    final sourceFileName = buildStep.inputId.pathSegments.last; // e.g. task_data.dart
    final baseName = sourceFileName.replaceAll('.dart', ''); // task_data
    final gPartName = '$baseName.entity_state.g.dart';
    buffer
      // Import the original source file so the original data class symbol
      // (e.g. TaskData) is in scope for the toData() mapper and any type
      // references. This keeps the generated library standalone while still
      // enabling the round-trip mapping.
      ..writeln("import 'package:json_annotation/json_annotation.dart';")
      ..writeln("import 'package:sltt_core/sltt_core.dart';")
      ..writeln()
      ..writeln("import '$sourceFileName';")
      ..writeln()
      ..writeln("part '$gPartName';")
      ..writeln();
    buffer.writeln(
      '@JsonSerializable(includeIfNull: $includeIfNull, explicitToJson: true)',
    );
    buffer.writeln('class $entityStateClassName extends BaseEntityState {');
    buffer.writeln(
      '  // json config: required=$jsonRequired includeIfNull=$includeIfNull',
    );
    buffer.writeln('  @override');
    buffer.writeln('  final String entityId;');

    // Data field declarations + meta markers per field
    for (final field in dataFields) {
      final name = field.name;
      final typeStr = field.type.getDisplayString(withNullability: true);
      buffer.writeln('  final $typeStr data_$name;');
      buffer.writeln('  final int? data_${name}_dataSchemaRev_;');
      buffer.writeln('  final DateTime? data_${name}_changeAt_;');
      buffer.writeln('  final String? data_${name}_cid_;');
      buffer.writeln('  final String? data_${name}_changeBy_;');
      buffer.writeln('  final DateTime? data_${name}_cloudAt_;');
    }

    // Constructor
    buffer.writeln('  $entityStateClassName({');
    buffer.writeln('    required this.entityId,');
    buffer.writeln(
      '    // entityType is fixed for this generated class and must not be overridden',
    );
    buffer.writeln('    required super.domainType,');
    buffer.writeln('    required super.change_domainId,');
    buffer.writeln('    required super.change_changeAt,');
    buffer.writeln('    required super.change_cid,');
    buffer.writeln('    required super.change_changeBy,');
    buffer.writeln('    required super.data_parentId,');
    buffer.writeln('    required super.data_parentId_changeAt_,');
    buffer.writeln('    required super.data_parentId_cid_,');
    buffer.writeln('    required super.data_parentId_changeBy_,');
    // parentProp is optional and may be absent from older change logs; pass nulls
    buffer.writeln('    // parentProp related meta (required to match BaseEntityState)');
    buffer.writeln('    required super.data_parentProp,');
    buffer.writeln('    super.data_parentProp_dataSchemaRev_,');
    buffer.writeln('    required super.data_parentProp_changeAt_,');
    buffer.writeln('    required super.data_parentProp_cid_,');
    buffer.writeln('    required super.data_parentProp_changeBy_,');
    buffer.writeln('    super.data_parentProp_cloudAt_,');
    buffer.writeln('    required super.unknownJson,');
    buffer.writeln('    super.change_dataSchemaRev,');
    buffer.writeln('    super.change_cloudAt,');
    buffer.writeln('    super.data_rank,');
    buffer.writeln('    super.data_rank_dataSchemaRev_,');
    buffer.writeln('    super.data_rank_changeAt_,');
    buffer.writeln('    super.data_rank_cid_,');
    buffer.writeln('    super.data_rank_changeBy_,');
    buffer.writeln('    super.data_rank_cloudAt_,');
    buffer.writeln('    super.data_deleted,');
    buffer.writeln('    super.data_deleted_dataSchemaRev_,');
    buffer.writeln('    super.data_deleted_changeAt_,');
    buffer.writeln('    super.data_deleted_cid_,');
    buffer.writeln('    super.data_deleted_changeBy_,');
    buffer.writeln('    super.data_deleted_cloudAt_,');

    for (final field in dataFields) {
      final name = field.name;
      buffer.writeln('    required this.data_$name,');
      buffer.writeln('    this.data_${name}_dataSchemaRev_,');
      buffer.writeln('    this.data_${name}_changeAt_,');
      buffer.writeln('    this.data_${name}_cid_,');
      buffer.writeln('    this.data_${name}_changeBy_,');
      buffer.writeln('    this.data_${name}_cloudAt_,');
    }

    buffer.writeln('  }) : super(');
    buffer.writeln('    entityId: entityId,');
    buffer.writeln("    entityType: '$entityTypeValue',");
    buffer.writeln('    change_domainId_orig_: change_domainId,');
    buffer.writeln('    change_changeAt_orig_: change_changeAt,');
    buffer.writeln('    change_cid_orig_: change_cid,');
    buffer.writeln('    change_changeBy_orig_: change_changeBy,');
    buffer.writeln('  );');

    // Base (json_serializable) helpers
    buffer.writeln(
      '  static $entityStateClassName fromJsonBase(Map<String,dynamic> json) => _\$${entityStateClassName}FromJson(json);',
    );
    buffer.writeln(
      '  Map<String,dynamic> toJsonBase() => _\$${entityStateClassName}ToJson(this);',
    );

    // toJsonSafe ensures required fields present building on domain toJson()
    buffer.writeln('  Map<String, dynamic> toJsonSafe() {');
    buffer.writeln('    final j = toJson();');
    for (final field in allFields) {
      final name = field.name;
      // Provide basic defaults based on type
      final typeStr = field.type.getDisplayString(withNullability: true);
      final defaultExpr = _defaultForType(typeStr);
      if (jsonRequired) {
        buffer.writeln("    j.putIfAbsent('data_$name', () => $defaultExpr);");
      }
    }
    buffer.writeln('    return j;');
    buffer.writeln('  }');

    // Unknown-field aware wrappers matching existing Isar pattern
    buffer.writeln(
      '  factory $entityStateClassName.fromJson(Map<String,dynamic> json) =>',
    );
    buffer.writeln('      deserializeWithUnknownFieldData(');
    buffer.writeln('        _\$${entityStateClassName}FromJson,');
    buffer.writeln('        json,');
    buffer.writeln('        _\$${entityStateClassName}ToJson,');
    buffer.writeln('      );');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  Map<String,dynamic> toJson() =>');
    buffer.writeln(
      '      serializeWithUnknownFieldData(this, _\$${entityStateClassName}ToJson);',
    );

    buffer.writeln('}');

    // Add toData() mapper after class to return the original data class instance
    buffer.writeln();
    buffer.writeln('// Mapper back to the original data class');
    buffer.writeln(
      '$className _${entityStateClassName}ToData($entityStateClassName s) => $className(',
    );
    for (final field in allFields) {
      final originalName = field.name;
      if (coreFieldNames.contains(originalName)) {
        // Map to base class field naming (data_<core>)
        buffer.writeln('  $originalName: s.data_$originalName,');
      } else {
        buffer.writeln('  $originalName: s.data_$originalName,');
      }
    }
    buffer.writeln(');');

    buffer.writeln(
      'extension ${entityStateClassName}DataExt on $entityStateClassName {',
    );
    buffer.writeln(
      '  $className toData() => _${entityStateClassName}ToData(this);',
    );
    buffer.writeln('}');

    return _formatter.format(buffer.toString());
  }
}

bool _isIsarCompatibleType(DartType type) {
  final t = type.getDisplayString(withNullability: false);
  const scalars = {'String', 'int', 'double', 'bool', 'DateTime'};
  if (scalars.contains(t)) return true;
  if (t.startsWith('List<')) return true; // heuristic; deeper validation later
  if (t.startsWith('Map<')) return true; // heuristic
  return false;
}

String _defaultForType(String typeStr) {
  if (typeStr.startsWith('String')) return "''";
  if (typeStr.startsWith('int')) return '0';
  if (typeStr.startsWith('double')) return '0.0';
  if (typeStr.startsWith('bool')) return 'false';
  if (typeStr.startsWith('DateTime')) {
    return 'DateTime.fromMillisecondsSinceEpoch(0).toUtc()';
  }
  if (typeStr.startsWith('List<')) return '[]';
  if (typeStr.startsWith('Map<')) return '{}';
  return 'null';
}

Builder syncableEntityStateDataBuilder(BuilderOptions options) => LibraryBuilder(
      SyncableEntityStateDataGenerator(),
      generatedExtension: '.entity_state.dart',
    );
