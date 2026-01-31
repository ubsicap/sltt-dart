# Prompt: Generate Dynamo Entity State Class and Tests

Follow this checklist to add DynamoDB entity state support and tests for a new entity type in this project, using `portion_translation.entity_state.dynamo.dart` and `portion_translation.data.dart` as exemplars:

---

1. **Create the Data Model**
   - Define a `*.data.dart` file for the entity using `@JsonSerializable`.
   - Ensure all fields required for serialization are present and match the domain model.

2. **Create the Dynamo Entity State Class**
   - Create a file named `*.entity_state.dynamo.dart`.
   - Define the Dynamo entity class, extending `BaseEntityState` and using `@JsonSerializable`.
   - Implement all required fields, including change tracking and data fields.
   - Add methods for serialization/deserialization (e.g., `fromJson`, `toJson`).

3. **Write Tests**
   - Add a test for serialization/deserialization (e.g., `test/<entity>_entity_state.dynamo_test.dart`).
   - Add a test for field coverage (e.g., `test/<entity>_entity_state.dynamo_field_coverage_test.dart`).
   - Use `offline_portion_translation.entity_state.dynamo_test.dart` and `portion_translation.entity_state.dynamo_field_coverage_test.dart` as references.

4. **Run Code Generation**
   - Run `flutter pub run build_runner build` to generate the `*.g.dart` files.

5. **Register the Entity State**
   - Register the new entity state class in `packages/aws_backend/lib/src/models/dynamo_entity_state_serialization_registry.dart` by adding a factory for your entity type, following the pattern for existing entities.

6. **Verify Integration**
   - Ensure the new entity state class is properly integrated with the DynamoDB storage layer.
   - Verify that all tests pass and the new entity is correctly stored and retrieved from DynamoDB.

---

Replace `<entity>` with your actual entity name. This prompt will guide the generation and testing of new Dynamo entity state classes according to the documented process.
