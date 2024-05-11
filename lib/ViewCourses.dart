// ignore_for_file: prefer_const_constructors, avoid_print, use_super_parameters, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'barcodescanner.dart';

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
          return GestureDetector(
            onTap: () {
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
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Add Student for courses')
                  .where('courses', arrayContains: courses[index])
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return ListTile(
                    title: Text(courses[index]),
                    subtitle: Text('No students registered for this course'),
                  );
                }

                List<String> studentRegNos =
                    snapshot.data!.docs.map((doc) => doc.id).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        courses[index],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: studentRegNos
                            .map((regNo) => Text('Student RegNo: $regNo'))
                            .toList(),
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
