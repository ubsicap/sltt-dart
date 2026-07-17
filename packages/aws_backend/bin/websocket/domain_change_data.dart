class DomainChangeData {
  DomainChangeData({
    required this.name,
    required this.lastDomainSeq,
    required this.lastDomainChangeAt,
  });

  final String name;
  final int lastDomainSeq;
  final DateTime lastDomainChangeAt;

  factory DomainChangeData.fromJson(Map<String, dynamic> json) {
    final lastDomainChangeAtValue = json['lastDomainChangeAt'];
    if (json['name'] == null ||
        json['lastDomainSeq'] == null ||
        lastDomainChangeAtValue == null) {
      throw const FormatException('Missing required domainChange data fields');
    }

    return DomainChangeData(
      name: json['name'] as String,
      lastDomainSeq: json['lastDomainSeq'] is int
          ? json['lastDomainSeq'] as int
          : int.parse(json['lastDomainSeq'].toString()),
      lastDomainChangeAt: lastDomainChangeAtValue is DateTime
          ? lastDomainChangeAtValue.toUtc()
          : DateTime.parse(lastDomainChangeAtValue as String).toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'lastDomainSeq': lastDomainSeq,
    'lastDomainChangeAt': lastDomainChangeAt.toUtc().toIso8601String(),
  };
}
