class Student {
  int id;
  int studentId;
  String firstname;
  String middlename;
  String lastname;
  String dob; // YYYY-MM-DD
  String email;
  int majorId;
  String? majorName; // for joined queries

  Student({
    required this.id,
    required this.studentId,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.dob,
    required this.email,
    required this.majorId,
    this.majorName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: int.parse(json['id'].toString()),
      studentId: int.parse(json['student_id'].toString()),
      firstname: json['firstname'],
      middlename: json['middlename'],
      lastname: json['lastname'],
      dob: json['dob'],
      email: json['email'],
      majorId: int.parse(json['major_id'].toString()),
      majorName: json['major_name'],
    );
  }

  String get fullName => '$firstname $middlename $lastname';
}
