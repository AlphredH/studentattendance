class Course {
  int id;
  String courseName;
  String courseCode;
  int majorId;

  Course({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.majorId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: int.parse(json['id'].toString()),
      courseName: json['course_name'],
      courseCode: json['course_code'],
      majorId: int.parse(json['major_id'].toString()),
    );
  }

  String get displayName => '$courseCode - $courseName';
}
