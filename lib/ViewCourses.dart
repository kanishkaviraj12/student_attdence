// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ViewCourses extends StatefulWidget {
  final String teacherName;

  const ViewCourses(this.teacherName, {Key? key}) : super(key: key);

  @override
  State<ViewCourses> createState() => _ViewCoursesState();
}

class _ViewCoursesState extends State<ViewCourses> {
  List<String> courses = []; // List to store courses fetched from the database

  @override
  void initState() {
    super.initState();
    // Call function to fetch courses when the widget initializes
    fetchCourses();
  }

  // Function to fetch courses from the database
  void fetchCourses() {
    // You can replace this with your actual database fetching logic
    // For demonstration, I'm just adding dummy courses
    setState(() {
      courses = ['Course 1', 'Course 2', 'Course 3'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses by ${widget.teacherName}'),
      ),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course ${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Description of ${courses[index]}',
                      style: TextStyle(fontSize: 16),
                    ),
                    // Add more details or actions here for each course
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
