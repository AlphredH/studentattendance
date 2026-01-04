import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/major.dart';
import '../models/course.dart';

class StudentForAttendance {
  int id;
  int studentId;
  String fullName;
  bool isPresent;

  StudentForAttendance({
    required this.id,
    required this.studentId,
    required this.fullName,
    this.isPresent = false,
  });

  factory StudentForAttendance.fromJson(Map<String, dynamic> json) {
    return StudentForAttendance(
      id: int.parse(json['id'].toString()),
      studentId: int.parse(json['student_id'].toString()),
      fullName: json['full_name'],
      isPresent: false,
    );
  }
}

class AddAttendanceNew extends StatefulWidget {
  const AddAttendanceNew({super.key});

  @override
  State<AddAttendanceNew> createState() => _AddAttendanceNewState();
}

class _AddAttendanceNewState extends State<AddAttendanceNew> {
  final TextEditingController _dateController = TextEditingController();

  List<Major> majors = [];
  List<Course> courses = [];
  List<StudentForAttendance> students = [];

  Major? selectedMajor;
  Course? selectedCourse;

  bool isLoading = true;
  bool isLoadingStudents = false;

  @override
  void initState() {
    super.initState();
    // Set default date to today
    _dateController.text = DateTime.now().toString().split(
      ' ',
    )[0]; // YYYY-MM-DD
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    await getMajors();
    setState(() => isLoading = false);
  }

  Future<void> getMajors() async {
    final url = Uri.parse('$baseURL/getMajors.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      setState(() {
        majors = (jsonResponse as List)
            .map((json) => Major.fromJson(json))
            .toList();
        if (majors.isNotEmpty) {
          selectedMajor = majors[0];
          getCoursesByMajor(majors[0].id);
        }
      });
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

        if (selectedCourse != null) {
          getStudentsByCourse(selectedCourse!.id);
        } else {
          students.clear();
        }
      });
    }
  }

  Future<void> getStudentsByCourse(int courseId) async {
    setState(() => isLoadingStudents = true);

    final url = Uri.parse(
      '$baseURL/getStudentsByCourse.php?course_id=$courseId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      setState(() {
        students = (jsonResponse as List)
            .map((json) => StudentForAttendance.fromJson(json))
            .toList();
        isLoadingStudents = false;
      });
    } else {
      setState(() {
        students.clear();
        isLoadingStudents = false;
      });
    }
  }

  Future<void> saveAttendance() async {
    if (selectedCourse == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a course')));
      return;
    }

    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students to record attendance for')),
      );
      return;
    }

    // Prepare attendance data
    List<Map<String, dynamic>> attendanceData = students.map((student) {
      return {
        'student_id': student.id,
        'course_id': selectedCourse!.id,
        'attendance_date': _dateController.text,
        'status': student.isPresent ? 1 : 0,
      };
    }).toList();

    final url = Uri.parse('$baseURL/createAttendanceBatch.php');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode({'attendances': attendanceData}),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save attendance')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Attendance'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Form Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    children: [
                      // Date Field
                      TextField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Date (YYYY-MM-DD)',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _dateController.text = picked.toString().split(
                                ' ',
                              )[0];
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Major Dropdown
                      DropdownButtonFormField<Major>(
                        value: selectedMajor,
                        items: majors.map((major) {
                          return DropdownMenuItem<Major>(
                            value: major,
                            child: Text(major.majorName),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedMajor = v;
                            if (v != null) {
                              getCoursesByMajor(v.id);
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Select Major',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Course Dropdown
                      DropdownButtonFormField<Course>(
                        value: selectedCourse,
                        items: courses.map((course) {
                          return DropdownMenuItem<Course>(
                            value: course,
                            child: Text(course.displayName),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedCourse = v;
                            if (v != null) {
                              getStudentsByCourse(v.id);
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Select Course',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Students List Section
                Expanded(
                  child: isLoadingStudents
                      ? const Center(child: CircularProgressIndicator())
                      : students.isEmpty
                      ? const Center(
                          child: Text(
                            'No students registered for this course',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(student.fullName),
                                subtitle: Text('ID: ${student.studentId}'),
                                trailing: Switch(
                                  value: student.isPresent,
                                  activeColor: Colors.green,
                                  onChanged: (value) {
                                    setState(() {
                                      student.isPresent = value;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Save Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: students.isEmpty ? null : saveAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      'Save Attendance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
