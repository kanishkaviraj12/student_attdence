// ignore_for_file: unnecessary_string_interpolations, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attdence/barcodescanner.dart';
// Import the page where you want to navigate

class ViewCourses extends StatefulWidget {
  final String teacherName;

  ViewCourses(this.teacherName, {Key? key}) : super(key: key);

  @override
  State<ViewCourses> createState() => _ViewCoursesState();
}

class _ViewCoursesState extends State<ViewCourses> {
  List<String> courses = [];

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  void fetchCourses() async {
    try {
      CollectionReference courseCollection =
          FirebaseFirestore.instance.collection('courses');

      // Querying courses related to the selected teacher
      QuerySnapshot querySnapshot = await courseCollection
          .where('instructor', isEqualTo: widget.teacherName)
          .get();

      List<String> fetchedCourses =
          querySnapshot.docs.map((doc) => doc['courseName'] as String).toList();

      setState(() {
        courses = fetchedCourses;
      });
    } catch (error) {
      print("Error fetching courses: $error");
    }
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
            child: GestureDetector(
              onTap: () {
                // Navigate to course details page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Barcodescanner(
                      courseName: courses[index],
                      teacherName: widget.teacherName,
                    ),
                  ),
                );
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${courses[index]}', // Fetching course names from Firestore
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
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
