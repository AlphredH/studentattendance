import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/student.dart';
import '../models/major.dart';
import '../models/course.dart';

class RegisterStudent extends StatefulWidget {
  const RegisterStudent({super.key});

  @override
  State<RegisterStudent> createState() => _RegisterStudentState();
}

class _RegisterStudentState extends State<RegisterStudent> {
  List<Student> students = [];
  List<Course> courses = [];

  Student? selectedStudent;
  Course? selectedCourse;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    await getStudents();

    setState(() => isLoading = false);
  }

  Future<void> getStudents() async {
    final url = Uri.parse('$baseURL/getStudents.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      setState(() {
        students = (jsonResponse as List)
            .map((json) => Student.fromJson(json))
            .toList();
        if (students.isNotEmpty) {
          selectedStudent = students[0];
          // Load courses for the first student's major
          getCoursesByMajor(students[0].majorId);
        }
      });
    }
  }

  void onStudentChanged(Student? student) {
    if (student != null) {
      setState(() {
        selectedStudent = student;
        selectedCourse = null;
        courses.clear();
      });
      getCoursesByMajor(student.majorId);
    }
  }

  Future<void> getCoursesByMajor(int majorId) async {
    final url = Uri.parse('$baseURL/getCoursesByMajor.php?major_id=$majorId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      setState(() {
        courses = (jsonResponse as List)
            .map((json) => Course.fromJson(json))
            .toList();
        selectedCourse = courses.isNotEmpty ? courses[0] : null;
      });
    }
  }

  Future<void> registerStudent() async {
    if (selectedStudent == null || selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select student and course')),
      );
      return;
    }

    final url = Uri.parse('$baseURL/registerStudentToCourse.php');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(<String, dynamic>{
        'student_id': selectedStudent!.id,
        'course_id': selectedCourse!.id,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student registered successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to register student')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Student to Course'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Student Dropdown
                      Container(
                        width: 300,
                        padding: const EdgeInsets.only(bottom: 20),
                        child: DropdownButtonFormField<Student>(
                          value: selectedStudent,
                          items: students.map((student) {
                            return DropdownMenuItem<Student>(
                              value: student,
                              child: Text(
                                '${student.studentId} - ${student.fullName}',
                              ),
                            );
                          }).toList(),
                          onChanged: onStudentChanged,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Select Student',
                          ),
                        ),
                      ),

                      // Display student's major (read-only)
                      if (selectedStudent != null)
                        Container(
                          width: 300,
                          padding: const EdgeInsets.only(bottom: 20),
                          child: TextFormField(
                            initialValue: selectedStudent!.majorName ?? 'N/A',
                            enabled: false,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Student\'s Major',
                              filled: true,
                              fillColor: Color(0xFFE0E0E0),
                            ),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Course Dropdown
                      Container(
                        width: 300,
                        padding: const EdgeInsets.only(bottom: 20),
                        child: DropdownButtonFormField<Course>(
                          value: selectedCourse,
                          items: courses.map((course) {
                            return DropdownMenuItem<Course>(
                              value: course,
                              child: Text(course.displayName),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => selectedCourse = v),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Select Course',
                          ),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: registerStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
