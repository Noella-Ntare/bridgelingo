class UserStats {
  final int totalXp;
  final int lessonsCompleted;
  final int streakDays;
  final int challengeLevel;

  UserStats({
    required this.totalXp,
    required this.lessonsCompleted,
    required this.streakDays,
    required this.challengeLevel,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalXp: json['totalXp'] ?? 0,
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      challengeLevel: json['challengeLevel'] ?? 1,
    );
  }
}
