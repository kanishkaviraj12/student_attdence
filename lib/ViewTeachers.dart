import 'package:flutter/material.dart';
import 'package:student_attdence/ViewCourses.dart';

class ViewTeachers extends StatelessWidget {
  final List<String> teacherNames = [
    'Teacher 1',
    'Teacher 2',
    'Teacher 3',
    'Teacher 4',
    'Teacher 5',
    // Add more teacher names as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teachers'),
      ),
      body: GridView.count(
        crossAxisCount: 1, // Number of columns
        childAspectRatio: 3.0, // Adjust the aspect ratio to change the height
        children: List.generate(teacherNames.length, (index) {
          return GestureDetector(
            onTap: () {
              // Navigate to ViewCourses page when a teacher is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewCourses(
                        teacherNames[index])), // Pass teacher name directly
              );
            },
            child: Card(
              child: Center(
                child: Text(
                  teacherNames[index],
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
