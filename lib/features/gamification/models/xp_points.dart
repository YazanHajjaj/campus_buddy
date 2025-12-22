/// Stores XP-related state for a user.
/// XP calculation and updates are handled elsewhere.
class XpPoints {
  final int totalXp;
  final int level;
  final String? lastEarnedFrom;
  final DateTime? lastUpdatedAt;

  const XpPoints({
    required this.totalXp,
    required this.level,
    this.lastEarnedFrom,
    this.lastUpdatedAt,
  });

  XpPoints copyWith({
    int? totalXp,
    int? level,
    String? lastEarnedFrom,
    DateTime? lastUpdatedAt,
  }) {
    return XpPoints(
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      lastEarnedFrom: lastEarnedFrom ?? this.lastEarnedFrom,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalXp': totalXp,
      'level': level,
      'lastEarnedFrom': lastEarnedFrom,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }

  factory XpPoints.fromMap(Map<String, dynamic> map) {
    return XpPoints(
      totalXp: map['totalXp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      lastEarnedFrom: map['lastEarnedFrom'] as String?,
      lastUpdatedAt: map['lastUpdatedAt'] != null
          ? DateTime.parse(map['lastUpdatedAt'] as String)
          : null,
    );
  }
}