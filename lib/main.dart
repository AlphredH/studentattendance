import 'package:flutter/material.dart';
import 'pages/main_menu.dart';

void main() {
  runApp(const MyApp());
}

const String baseURL =
    'http://studentsattendance-dev.atwebpages.com/'; // <- change this

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainMenu(),
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
    );
  }
}
