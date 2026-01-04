import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'add_student.dart';
import 'edit_student.dart';
import 'edit_student_courses.dart';

class StudentWithCourses {
  int id;
  int studentId;
  String firstname;
  String middlename;
  String lastname;
  String dob;
  String email;
  int majorId;
  String majorName;
  List<String> courses;

  StudentWithCourses({
    required this.id,
    required this.studentId,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.dob,
    required this.email,
    required this.majorId,
    required this.majorName,
    required this.courses,
  });

  String get fullName => '$firstname $middlename $lastname';

  factory StudentWithCourses.fromJson(Map<String, dynamic> json) {
    return StudentWithCourses(
      id: int.parse(json['id'].toString()),
      studentId: int.parse(json['student_id'].toString()),
      firstname: json['firstname'],
      middlename: json['middlename'],
      lastname: json['lastname'],
      dob: json['dob'],
      email: json['email'],
      majorId: int.parse(json['major_id'].toString()),
      majorName: json['major_name'] ?? 'N/A',
      courses: json['courses'] != null
          ? List<String>.from(json['courses'])
          : [],
    );
  }
}

class ListStudents extends StatefulWidget {
  const ListStudents({super.key});

  @override
  State<ListStudents> createState() => _ListStudentsState();
}

class _ListStudentsState extends State<ListStudents> {
  List<StudentWithCourses> all = [];
  List<StudentWithCourses> searchResults = [];
  String searchKeyword = '';

  @override
  void initState() {
    super.initState();
    getStudents();
  }

  Future<bool> getStudents() async {
    all.clear();
    searchResults.clear();

    final url = Uri.parse('$baseURL/getStudentsWithCourses.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      for (var row in jsonResponse) {
        StudentWithCourses s = StudentWithCourses.fromJson(row);

        setState(() {
          all.add(s);
        });
      }
    }

    // default: show all records
    setState(() {
      searchResults = List.from(all);
    });

    return true;
  }

  void search(String s) {
    searchKeyword = s;

    setState(() {
      searchResults.clear();
    });

    if (s.trim().isEmpty) {
      setState(() {
        searchResults = List.from(all);
      });
      return;
    }

    String key = s.trim().toLowerCase();

    for (int i = 0; i < all.length; i++) {
      if (all[i].fullName.toLowerCase().contains(key) ||
          all[i].studentId.toString().contains(key) ||
          all[i].email.toLowerCase().contains(key) ||
          all[i].majorName.toLowerCase().contains(key)) {
        setState(() {
          searchResults.add(all[i]);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyTextField(f: search),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => AddStudent()));
              await getStudents();
              search(searchKeyword);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: searchResults.length,
        itemBuilder: (c, i) {
          final s = searchResults[i];

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditStudent(
                      studentId: s.studentId,
                      studentDbId: s.id,
                      firstname: s.firstname,
                      middlename: s.middlename,
                      lastname: s.lastname,
                      dob: s.dob,
                      email: s.email,
                      majorId: s.majorId,
                    ),
                  ),
                );
                if (result == true) {
                  await getStudents();
                  search(searchKeyword);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple.shade200),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.purple.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // top row: student name and edit buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            s.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.school,
                                color: Colors.orange,
                                size: 20,
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditStudentCourses(
                                      studentId: s.studentId,
                                      studentDbId: s.id,
                                      studentName: s.fullName,
                                      majorId: s.majorId,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  await getStudents();
                                  search(searchKeyword);
                                }
                              },
                              tooltip: 'Manage Courses',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.edit,
                              color: Colors.purple,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Student ID: ${s.studentId}'),
                    Text('Email: ${s.email}'),
                    Text('Date of Birth: ${s.dob}'),
                    Text('Major: ${s.majorName}'),
                    const SizedBox(height: 8),
                    if (s.courses.isNotEmpty) ...[
                      const Text(
                        'Registered Courses:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ...s.courses.map(
                        (course) => Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 2),
                          child: Text('• $course'),
                        ),
                      ),
                    ] else
                      const Text(
                        'No courses registered',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  MyTextField({super.key, required this.f});
  final Function(String s) f;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Search name / id / email / major',
        prefixIcon: Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: f,
    );
  }
}
