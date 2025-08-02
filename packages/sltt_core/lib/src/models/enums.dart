/// Enum for difficulty levels used across entities
enum Difficulty {
  veryEasy('very_easy'),
  easy('easy'),
  medium('medium'),
  hard('hard'),
  veryHard('very_hard');

  const Difficulty(this.value);

  /// The string representation of the difficulty level
  final String value;

  /// Convert from string to Difficulty enum
  static Difficulty fromString(String value) {
    for (final difficulty in Difficulty.values) {
      if (difficulty.value.toLowerCase() == value.toLowerCase()) {
        return difficulty;
      }
    }
    throw ArgumentError('Unknown difficulty: $value');
  }

  /// Convert from string to Difficulty enum, returning null for unknown values
  static Difficulty? tryFromString(String? value) {
    if (value == null) return null;
    try {
      return fromString(value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => value;
}

/// Enum for status levels used across entities
enum Status {
  draft('draft'),
  inProgress('in_progress'),
  review('review'),
  approved('approved'),
  published('published'),
  archived('archived');

  const Status(this.value);

  /// The string representation of the status
  final String value;

  /// Convert from string to Status enum
  static Status fromString(String value) {
    for (final status in Status.values) {
      if (status.value.toLowerCase() == value.toLowerCase()) {
        return status;
      }
    }
    throw ArgumentError('Unknown status: $value');
  }

  /// Convert from string to Status enum, returning null for unknown values
  static Status? tryFromString(String? value) {
    if (value == null) return null;
    try {
      return fromString(value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => value;
}

/// Enum for priority levels used across entities
enum Priority {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const Priority(this.value);

  /// The string representation of the priority
  final String value;

  /// Convert from string to Priority enum
  static Priority fromString(String value) {
    for (final priority in Priority.values) {
      if (priority.value.toLowerCase() == value.toLowerCase()) {
        return priority;
      }
    }
    throw ArgumentError('Unknown priority: $value');
  }

  /// Convert from string to Priority enum, returning null for unknown values
  static Priority? tryFromString(String? value) {
    if (value == null) return null;
    try {
      return fromString(value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => value;
}

/// Enum for project types
enum ProjectType {
  translation('translation'),
  dubbing('dubbing'),
  signLanguage('sign_language'),
  accessibility('accessibility'),
  other('other');

  const ProjectType(this.value);

  /// The string representation of the project type
  final String value;

  /// Convert from string to ProjectType enum
  static ProjectType fromString(String value) {
    for (final projectType in ProjectType.values) {
      if (projectType.value.toLowerCase() == value.toLowerCase()) {
        return projectType;
      }
    }
    throw ArgumentError('Unknown project type: $value');
  }

  /// Convert from string to ProjectType enum, returning null for unknown values
  static ProjectType? tryFromString(String? value) {
    if (value == null) return null;
    try {
      return fromString(value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => value;
}

/// Enum for passage types
enum PassageType {
  translation('translation'),
  introduction('introduction'),
  other('other');

  const PassageType(this.value);

  /// The string representation of the passage type
  final String value;

  /// Convert from string to PassageType enum
  static PassageType fromString(String value) {
    for (final passageType in PassageType.values) {
      if (passageType.value.toLowerCase() == value.toLowerCase()) {
        return passageType;
      }
    }
    throw ArgumentError('Unknown passage type: $value');
  }

  /// Convert from string to PassageType enum, returning null for unknown values
  static PassageType? tryFromString(String? value) {
    if (value == null) return null;
    try {
      return fromString(value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => value;
}

/// Enum for draft video types
enum DraftType {
  translation('translation'),
  introduction('introduction'),
  other('other');

  const DraftType(this.value);

  /// The string representation of the draft type
  final String value;

  /// Convert from string to DraftType enum
  static DraftType fromString(String value) {
    for (final draftType in DraftType.values) {
      if (draftType.value.toLowerCase() == value.toLowerCase()) {
        return draftType;
      }
    }
    throw ArgumentError('Unknown draft type: $value');
  }

  /// Convert from string to DraftType enum, returning null for unknown values
  static DraftType? tryFromString(String? value) {
    if (value == null) return null;
    try {
      return fromString(value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => value;
}
