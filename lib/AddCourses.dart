// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCourses extends StatefulWidget {
  const AddCourses({super.key});

  @override
  State<AddCourses> createState() => _AddCoursesState();
}

class Course {
  String courseName;
  String instructor;

  Course({required this.courseName, required this.instructor});
}

class _AddCoursesState extends State<AddCourses> {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Course'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _courseNameController,
              decoration: InputDecoration(labelText: 'Course Name'),
            ),
            TextFormField(
              controller: _instructorController,
              decoration: InputDecoration(labelText: 'Instructor'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                saveCourseToFirestore(
                  courseName: _courseNameController.text,
                  instructor: _instructorController.text,
                );
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> saveCourseToFirestore({
  required String courseName,
  required String instructor,
}) async {
  try {
    await FirebaseFirestore.instance.collection('courses').add({
      'courseName': courseName,
      'instructor': instructor,
    });
    print('Course added successfully');
  } catch (e) {
    print('Error adding course: $e');
  }
}
