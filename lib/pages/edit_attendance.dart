import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class EditAttendance extends StatefulWidget {
  final int attendanceId;
  final String studentName;
  final String courseName;
  final String date;
  final int status;

  const EditAttendance({
    super.key,
    required this.attendanceId,
    required this.studentName,
    required this.courseName,
    required this.date,
    required this.status,
  });

  @override
  State<EditAttendance> createState() => _EditAttendanceState();
}

class _EditAttendanceState extends State<EditAttendance> {
  late int selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.status;
  }

  Future<void> updateAttendance() async {
    final url = Uri.parse('$baseURL/updateAttendance.php');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(<String, dynamic>{
        'id': widget.attendanceId,
        'status': selectedStatus,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update attendance')),
      );
    }
  }

  Future<void> deleteAttendance() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attendance'),
        content: const Text(
          'Are you sure you want to delete this attendance record?',
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

    final url = Uri.parse('$baseURL/deleteAttendance.php');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(<String, dynamic>{'id': widget.attendanceId}),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete attendance')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Attendance'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteAttendance,
            tooltip: 'Delete Attendance',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _infoRow('Student:', widget.studentName),
            const SizedBox(height: 12),
            _infoRow('Course:', widget.courseName),
            const SizedBox(height: 12),
            _infoRow('Date:', widget.date),
            const SizedBox(height: 24),
            Card(
              child: SwitchListTile(
                title: const Text(
                  'Attendance Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  selectedStatus == 1 ? 'Present' : 'Absent',
                  style: TextStyle(
                    color: selectedStatus == 1 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: selectedStatus == 1,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value ? 1 : 0;
                  });
                },
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Update Attendance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
