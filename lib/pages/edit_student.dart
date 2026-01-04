import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/major.dart';

class EditStudent extends StatefulWidget {
  final int studentId;
  final int studentDbId;
  final String firstname;
  final String middlename;
  final String lastname;
  final String dob;
  final String email;
  final int majorId;

  const EditStudent({
    super.key,
    required this.studentId,
    required this.studentDbId,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.dob,
    required this.email,
    required this.majorId,
  });

  @override
  State<EditStudent> createState() => _EditStudentState();
}

class _EditStudentState extends State<EditStudent> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late TextEditingController _studentIdController;
  late TextEditingController _firstnameController;
  late TextEditingController _middlenameController;
  late TextEditingController _lastnameController;
  late TextEditingController _dobController;
  late TextEditingController _emailController;

  List<Major> majors = [];
  Major? selectedMajor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _studentIdController = TextEditingController(
      text: widget.studentId.toString(),
    );
    _firstnameController = TextEditingController(text: widget.firstname);
    _middlenameController = TextEditingController(text: widget.middlename);
    _lastnameController = TextEditingController(text: widget.lastname);
    _dobController = TextEditingController(text: widget.dob);
    _emailController = TextEditingController(text: widget.email);

    getMajors();
  }

  Future<void> getMajors() async {
    setState(() => isLoading = true);

    final url = Uri.parse('$baseURL/getMajors.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      setState(() {
        majors = (jsonResponse as List)
            .map((json) => Major.fromJson(json))
            .toList();
        // Set the current major as selected
        selectedMajor = majors.firstWhere(
          (m) => m.id == widget.majorId,
          orElse: () =>
              majors.isNotEmpty ? majors[0] : Major(id: 0, majorName: ''),
        );
        isLoading = false;
      });
    }
  }

  Future<void> updateStudent() async {
    if (selectedMajor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a major')));
      return;
    }

    final url = Uri.parse('$baseURL/updateStudent.php');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(<String, dynamic>{
        'id': widget.studentDbId,
        'student_id': _studentIdController.text,
        'firstname': _firstnameController.text,
        'middlename': _middlenameController.text,
        'lastname': _lastnameController.text,
        'dob': _dobController.text,
        'email': _emailController.text,
        'major_id': selectedMajor!.id,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(true); // Return true to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update student')));
    }
  }

  Future<void> deleteStudent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text(
          'Are you sure you want to delete this student? This will also remove all their course registrations and attendance records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final url = Uri.parse('$baseURL/deleteStudent.php');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(<String, dynamic>{'id': widget.studentDbId}),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete student')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteStudent,
            tooltip: 'Delete Student',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _field(
                          controller: _studentIdController,
                          hint: 'Enter student ID (e.g., 62110101)',
                          validatorMsg: 'You must enter the student ID',
                          keyboardType: TextInputType.number,
                        ),
                        _field(
                          controller: _firstnameController,
                          hint: 'Enter first name',
                          validatorMsg: 'You must enter the first name',
                        ),
                        _field(
                          controller: _middlenameController,
                          hint: 'Enter middle name',
                          validatorMsg: 'You must enter the middle name',
                        ),
                        _field(
                          controller: _lastnameController,
                          hint: 'Enter last name',
                          validatorMsg: 'You must enter the last name',
                        ),
                        _field(
                          controller: _dobController,
                          hint: 'Enter date of birth (YYYY-MM-DD)',
                          validatorMsg: 'You must enter the date of birth',
                        ),
                        _field(
                          controller: _emailController,
                          hint: 'Enter email',
                          validatorMsg: 'You must enter the email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        Container(
                          width: 260,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DropdownButtonFormField<Major>(
                            value: selectedMajor,
                            items: majors.map((major) {
                              return DropdownMenuItem<Major>(
                                value: major,
                                child: Text(major.majorName),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => selectedMajor = v),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select major',
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              updateStudent();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required String validatorMsg,
    TextInputType? keyboardType,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hint,
        ),
        validator: (s) {
          if (s == null || s.isEmpty) return validatorMsg;
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _firstnameController.dispose();
    _middlenameController.dispose();
    _lastnameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
