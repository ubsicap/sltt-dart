import 'package:sltt_core/sltt_core.dart';

class CloudDomainStatsUpdate {
  CloudDomainStatsUpdate({
    required this.domainType,
    required this.domainId,
    required this.cloudStats,
    required this.observedAt,
  });

  final String domainType;
  final String domainId;
  final DomainStatsResponse cloudStats;
  final DateTime observedAt;

  factory CloudDomainStatsUpdate.fromJson(Map<String, dynamic> json) {
    return CloudDomainStatsUpdate(
      domainType: json['domainType'] as String,
      domainId: json['domainId'] as String,
      cloudStats: DomainStatsResponse.fromJson(
        Map<String, dynamic>.from(json['cloudStats'] as Map),
      ),
      observedAt: DateTime.parse(json['observedAt'] as String).toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'domainType': domainType,
      'domainId': domainId,
      'cloudStats': cloudStats.toJson(),
      'observedAt': observedAt.toUtc().toIso8601String(),
    };
  }
}

class LocalDomainStatsUpdate {
  LocalDomainStatsUpdate({
    required this.domainType,
    required this.domainId,
    required this.localChangeStats,
    required this.localStateStats,
    required this.observedAt,
  });

  final String domainType;
  final String domainId;
  final EntityTypeStats localChangeStats;
  final EntityTypeStats localStateStats;
  final DateTime observedAt;

  factory LocalDomainStatsUpdate.fromJson(Map<String, dynamic> json) {
    return LocalDomainStatsUpdate(
      domainType: json['domainType'] as String,
      domainId: json['domainId'] as String,
      localChangeStats: EntityTypeStats.fromJson(
        Map<String, dynamic>.from(json['localChangeStats'] as Map),
      ),
      localStateStats: EntityTypeStats.fromJson(
        Map<String, dynamic>.from(json['localStateStats'] as Map),
      ),
      observedAt: DateTime.parse(json['observedAt'] as String).toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'domainType': domainType,
      'domainId': domainId,
      'localChangeStats': localChangeStats.toJson(),
      'localStateStats': localStateStats.toJson(),
      'observedAt': observedAt.toUtc().toIso8601String(),
    };
  }
}
