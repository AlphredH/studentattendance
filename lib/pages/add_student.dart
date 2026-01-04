import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/major.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _middlenameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<Major> majors = [];
  Major? selectedMajor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
        if (majors.isNotEmpty) {
          selectedMajor = majors[0];
        }
        isLoading = false;
      });
    }
  }

  Future<void> createStudent() async {
    if (selectedMajor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a major')));
      return;
    }

    final url = Uri.parse('$baseURL/createStudent.php');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(<String, dynamic>{
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
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add student')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
                              createStudent();
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
                            'Save',
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
}
