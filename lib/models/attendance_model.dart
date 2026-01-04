class AttendanceModel {
  int id;
  int studentId;
  int courseId;
  String attendanceDate; // YYYY-MM-DD HH:MM:SS
  int status; // 0=Absent, 1=Present

  // For display (from joined queries)
  String? studentName;
  String? courseName;
  String? courseCode;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.attendanceDate,
    required this.status,
    this.studentName,
    this.courseName,
    this.courseCode,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: int.parse(json['id'].toString()),
      studentId: int.parse(json['student_id'].toString()),
      courseId: int.parse(json['course_id'].toString()),
      attendanceDate: json['attendance_date'],
      status: int.parse(json['status'].toString()),
      studentName: json['student_name'],
      courseName: json['course_name'],
      courseCode: json['course_code'],
    );
  }

  String get statusText => status == 1 ? 'Present' : 'Absent';

  String get dateOnly => attendanceDate.split(' ')[0]; // Get YYYY-MM-DD part
}
