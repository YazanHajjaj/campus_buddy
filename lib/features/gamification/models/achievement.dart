/// Represents a progress-based achievement.
/// Progress is updated elsewhere (analytics / services).
class Achievement {
  final String id;
  final String title;
  final String description;
  final int requiredCount;
  final int currentCount;
  final bool completed;
  final DateTime? completedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredCount,
    required this.currentCount,
    required this.completed,
    this.completedAt,
  });

  Achievement copyWith({
    int? currentCount,
    bool? completed,
    DateTime? completedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      requiredCount: requiredCount,
      currentCount: currentCount ?? this.currentCount,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requiredCount': requiredCount,
      'currentCount': currentCount,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      requiredCount: map['requiredCount'] as int,
      currentCount: map['currentCount'] as int? ?? 0,
      completed: map['completed'] as bool? ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }
}