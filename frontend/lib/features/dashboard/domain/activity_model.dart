class RecentActivity {
  final String lessonTitle;
  final int score;
  final String date;

  RecentActivity({required this.lessonTitle, required this.score, required this.date});

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      lessonTitle: json['lesson']['title'] ?? 'Unknown Lesson',
      score: json['score'] ?? 0,
      date: json['completedAt'] ?? '',
    );
  }
}
