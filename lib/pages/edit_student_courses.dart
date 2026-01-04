import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/course.dart';

class EditStudentCourses extends StatefulWidget {
  final int studentId;
  final int studentDbId;
  final String studentName;
  final int majorId;

  const EditStudentCourses({
    super.key,
    required this.studentId,
    required this.studentDbId,
    required this.studentName,
    required this.majorId,
  });

  @override
  State<EditStudentCourses> createState() => _EditStudentCoursesState();
}

class _EditStudentCoursesState extends State<EditStudentCourses> {
  List<Course> allCourses = [];
  List<int> registeredCourseIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    await getCourses();
    await getRegisteredCourses();
    setState(() => isLoading = false);
  }

  Future<void> getCourses() async {
    final url = Uri.parse(
      '$baseURL/getCoursesByMajor.php?major_id=${widget.majorId}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        allCourses = (jsonResponse as List)
            .map((json) => Course.fromJson(json))
            .toList();
      });
    }
  }

  Future<void> getRegisteredCourses() async {
    final url = Uri.parse(
      '$baseURL/getStudentCourses.php?student_id=${widget.studentDbId}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        registeredCourseIds = (jsonResponse as List)
            .map((json) => int.parse(json['course_id'].toString()))
            .toList();
      });
    }
  }

  Future<void> toggleCourse(int courseId, bool isRegistered) async {
    if (isRegistered) {
      // Register
      final url = Uri.parse('$baseURL/registerStudentToCourse.php');
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, dynamic>{
          'student_id': widget.studentDbId,
          'course_id': courseId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          registeredCourseIds.add(courseId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Course registered')));
      }
    } else {
      // Unregister
      final url = Uri.parse('$baseURL/unregisterStudentFromCourse.php');
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, dynamic>{
          'student_id': widget.studentDbId,
          'course_id': courseId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          registeredCourseIds.remove(courseId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Course unregistered')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses - ${widget.studentName}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allCourses.isEmpty
          ? const Center(child: Text('No courses available for this major'))
          : ListView.builder(
              itemCount: allCourses.length,
              itemBuilder: (context, index) {
                final course = allCourses[index];
                final isRegistered = registeredCourseIds.contains(course.id);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: SwitchListTile(
                    title: Text(
                      course.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Course ID: ${course.id}'),
                    value: isRegistered,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      toggleCourse(course.id, value);
                    },
                  ),
                );
              },
            ),
    );
  }
}
