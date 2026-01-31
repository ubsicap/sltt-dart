# Prompt: Generate Dynamo Entity State Class and Tests

Follow this checklist to add DynamoDB entity state support and tests for a new entity type in this project, using `portion_translation.entity_state.dynamo.dart` and `portion_translation.data.dart` as exemplars:

---

1. **Create the Data Model**
   - Copy the `*.data.dart` and `*.data.g.dart` files from sltt_standalone_app:
     - Source: sltt-standalone-app/lib/sltt/models/*<entity>*.data.dart
     - Target: packages/aws_backend/lib/src/models/<entity>.data.dart
     - Target: packages/aws_backend/lib/src/models/<entity>.data.g.dart
   - Ensure the `part` file name matches the target location.

2. **Create the Dynamo Entity State Class**
   - Create a file named `<entity>.entity_state.dynamo.dart` in packages/aws_backend/lib/src/models.
   - Define the Dynamo entity class, extending `BaseEntityState` and using `@JsonSerializable`.
   - Implement all required fields, including change tracking and data fields (mirror the data model).
   - Add methods for serialization/deserialization (`fromJson`, `fromJsonBase`, `toJson`, `toJsonBase`, `toJsonSafe`).

3. **Write Tests**
    - Add an offline serialization/deserialization test:
       - packages/aws_backend/test/offline_<entity>.entity_state.dynamo_test.dart
       - Use offline_portion_translation.entity_state.dynamo_test.dart as a reference.
    - Add field-coverage tests:
       - Offline: packages/aws_backend/test/offline_<entity>.entity_state.dynamo_field_coverage_test.dart
       - Online: packages/aws_backend/test/<entity>.entity_state.dynamo_field_coverage_test.dart
       - Use offline_portion_translation.entity_state.dynamo_field_coverage_test.dart and
          portion_translation.entity_state.dynamo_field_coverage_test.dart as references.

4. **Run Code Generation**
   - Run build runner in packages/aws_backend to generate `*.g.dart` files:
     - `dart run build_runner build --delete-conflicting-outputs`

5. **Register the Entity State**
   - Register the new entity state class in packages/aws_backend/lib/src/models/dynamo_entity_state_serialization_registry.dart
     by adding a factory for your entity type, following the pattern for existing entities.

6. **Verify Integration**
   - Ensure the new entity state class is properly integrated with the DynamoDB storage layer.
   - Verify that all Dynamo tests pass and the new entity is correctly stored and retrieved from DynamoDB.

---

Replace `<entity>` with your actual entity name. This prompt will guide the generation and testing of new Dynamo entity state classes according to the documented process.
