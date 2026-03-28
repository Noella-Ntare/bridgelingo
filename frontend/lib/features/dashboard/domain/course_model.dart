class Course {
  final String id;
  final String title;
  final String description;
  final String level;
  final String imageUrl;
  final List<Lesson> lessons;
  final double progress;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.imageUrl,
    this.lessons = const [],
    this.progress = 0.0,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Check if it's the wrapped DTO (has 'course' key) or direct Course
    final courseData = json.containsKey('course') ? json['course'] : json;
    final progressVal = json.containsKey('progress') ? (json['progress'] as num).toDouble() : 0.0;

    return Course(
      id: courseData['id'],
      title: courseData['title'],
      description: courseData['description'],
      level: courseData['level'],
      imageUrl: courseData['imageUrl'] ?? '',
      lessons: (courseData['lessons'] as List? ?? []).map((e) => Lesson.fromJson(e)).toList(),
      progress: progressVal,
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String content;
  final int orderIndex;
  final List<Exercise> exercises;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.orderIndex,
    this.exercises = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      orderIndex: json['orderIndex'],
      exercises: (json['exercises'] as List? ?? []).map((e) => Exercise.fromJson(e)).toList(),
    );
  }
}

class Exercise {
  final String id;
  final String type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? audioUrl;

  Exercise({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.audioUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      type: json['type'],
      question: json['question'],
      options: (json['options'] as List? ?? []).map((e) => e.toString()).toList(),
      correctAnswer: json['correctAnswer'] ?? '',
      audioUrl: json['audioUrl'],
    );
  }
}
