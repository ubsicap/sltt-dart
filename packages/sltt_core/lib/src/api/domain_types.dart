// Generated helper constants and accessors for domain types and collections
const String kDomainProject = 'project';
const String kCollectionProject = 'projects';

/// Returns all supported domain types.
List<String> getAllDomainTypes() => [kDomainProject];

/// Returns the collection name for a given domain type.
/// Example: getCollectionByDomain('project') → 'projects'
String? getCollectionByDomain(String domainType) {
  switch (domainType) {
    case kDomainProject:
      return kCollectionProject;
    default:
      return null;
  }
}

/// Returns the domain type for a given collection name.
/// Example: getDomainByCollection('projects') → 'project'
String? getDomainByCollection(String collectionName) {
  switch (collectionName) {
    case kCollectionProject:
      return kDomainProject;
    default:
      return null;
  }
}

/// API Helper Documentation
///
/// ## API Helper Functions
///
/// - `getAllDomainTypes()`
///   Returns a list of all supported domain types.
///
/// - `getCollectionByDomain(String domainType)`
///   Returns the collection name for a given domain type, or null if not found.
///   Example: `getCollectionByDomain('project')` → `'projects'`
///
/// - `getDomainByCollection(String collectionName)`
///   Returns the domain type for a given collection name, or null if not found.
///   Example: `getDomainByCollection('projects')` → `'project'`
