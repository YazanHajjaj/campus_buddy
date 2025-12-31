/// Represents a single leaderboard entry.
/// This is a pure data model (NO UI, NO navigation).
class LeaderboardEntry {
  /// Firebase user id
  final String uid;

  /// Display name shown on leaderboard
  final String name;

  /// Optional profile image URL
  final String? profileImage;

  /// XP score (used for ranking)
  final int score;

  /// Rank position (1 = top)
  final int rank;

  const LeaderboardEntry({
    required this.uid,
    required this.name,
    this.profileImage,
    required this.score,
    required this.rank,
  });

  /// Create a copy with updated values
  LeaderboardEntry copyWith({
    int? score,
    int? rank,
  }) {
    return LeaderboardEntry(
      uid: uid,
      name: name,
      profileImage: profileImage,
      score: score ?? this.score,
      rank: rank ?? this.rank,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'profileImage': profileImage,
      'score': score,
      'rank': rank,
    };
  }

  /// Create from Firestore document data
  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      uid: map['uid'] as String,
      name: map['name'] as String,
      profileImage: map['profileImage'] as String?,
      score: (map['score'] as num?)?.toInt() ?? 0,
      rank: (map['rank'] as num?)?.toInt() ?? 0,
    );
  }
}