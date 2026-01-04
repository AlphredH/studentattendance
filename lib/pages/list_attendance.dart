import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/attendance_model.dart';
import 'add_attendance_new.dart';
import 'edit_attendance.dart';

class ListAttendance extends StatefulWidget {
  const ListAttendance({super.key});

  @override
  State<ListAttendance> createState() => _ListAttendanceState();
}

class _ListAttendanceState extends State<ListAttendance> {
  @override
  void initState() {
    super.initState();
    getAttendance();
  }

  List<AttendanceModel> all = [];
  List<AttendanceModel> searchResults = [];
  String searchKeyword = '';

  Future<bool> getAttendance() async {
    all.clear();
    searchResults.clear();

    final url = Uri.parse('$baseURL/getTodayAttendance.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      for (var row in jsonResponse) {
        AttendanceModel a = AttendanceModel.fromJson(row);

        setState(() {
          all.add(a);
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
      if (all[i].studentName!.toLowerCase().contains(key) ||
          all[i].courseName!.toLowerCase().contains(key) ||
          all[i].courseCode!.toLowerCase().contains(key) ||
          all[i].statusText.toLowerCase().contains(key)) {
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddAttendanceNew()),
              );
              await getAttendance();
              search(searchKeyword);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: searchResults.isEmpty
          ? const Center(
              child: Text(
                'No attendance records for today',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: searchResults.length,
              itemBuilder: (c, i) {
                final a = searchResults[i];

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAttendance(
                            attendanceId: a.id,
                            studentName: a.studentName ?? 'Unknown',
                            courseName: '${a.courseCode} - ${a.courseName}',
                            date: a.dateOnly,
                            status: a.status,
                          ),
                        ),
                      );
                      if (result == true) {
                        await getAttendance();
                        search(searchKeyword);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(10),
                        color: a.status == 1
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // top row: student + status + edit icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  a.studentName ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: a.status == 1
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      a.statusText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Course: ${a.courseCode} - ${a.courseName}'),
                          Text('Date: ${a.dateOnly}'),
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
        hintText: 'Search student / course / status',
        prefixIcon: Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: f,
    );
  }
}
