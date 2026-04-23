// Generated helper constants and accessors for domain types and collections
const String kDomainProject = 'project';
const String kCollectionProject = 'projects';

const String kDomainUser = 'user';
const String kCollectionUser = 'users';

const String kDomainMembership = 'membership';
const String kCollectionMembership = 'memberships';

enum DomainType {
  project(value: kDomainProject),
  user(value: kDomainUser),
  membership(value: kDomainMembership),
  unknown(value: 'unknown');

  final String value;

  const DomainType({required this.value});

  static DomainType tryFromString(String value) {
    switch (value) {
      case kDomainProject:
        return DomainType.project;
      case kDomainUser:
        return DomainType.user;
      case kDomainMembership:
        return DomainType.membership;
      default:
        return DomainType.unknown;
    }
  }

  String get collectionName {
    switch (this) {
      case DomainType.project:
        return kCollectionProject;
      case DomainType.user:
        return kCollectionUser;
      case DomainType.membership:
        return kCollectionMembership;
      case DomainType.unknown:
        throw Exception('Unknown domain type does not have a collection name');
    }
  }
}

/// Returns all supported domain types.
List<String> getAllDomainTypes() => [
  kDomainProject,
  kDomainUser,
  kDomainMembership,
];

/// Returns the collection name for a given domain type.
/// Example: getCollectionByDomain('project') → 'projects'
String? getCollectionByDomain(String domainType) {
  switch (domainType) {
    case kDomainProject:
      return kCollectionProject;
    case kDomainUser:
      return kCollectionUser;
    case kDomainMembership:
      return kCollectionMembership;
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
    case kCollectionUser:
      return kDomainUser;
    case kCollectionMembership:
      return kDomainMembership;
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
