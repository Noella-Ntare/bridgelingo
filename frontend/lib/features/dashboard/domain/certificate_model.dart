class Certificate {
  final String id;
  final String courseTitle;
  final String certificateCode;
  final String issueDate;

  Certificate({
    required this.id,
    required this.courseTitle,
    required this.certificateCode,
    required this.issueDate,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      courseTitle: json['course']['title'] ?? 'Course',
      certificateCode: json['certificateCode'],
      issueDate: json['issueDate'],
    );
  }
}
