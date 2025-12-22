/// Represents a single leaderboard entry.
/// Ranking and aggregation are handled elsewhere.
class LeaderboardEntry {
  final String uid;
  final String name;
  final String? profileImage;
  final int score;
  final int rank;

  const LeaderboardEntry({
    required this.uid,
    required this.name,
    this.profileImage,
    required this.score,
    required this.rank,
  });

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

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'profileImage': profileImage,
      'score': score,
      'rank': rank,
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      uid: map['uid'] as String,
      name: map['name'] as String,
      profileImage: map['profileImage'] as String?,
      score: map['score'] as int? ?? 0,
      rank: map['rank'] as int? ?? 0,
    );
  }
}