// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attdence/ViewCourses.dart';

class ViewTeachers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teachers'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No teachers found'),
            );
          }

          // Extract teacher names from Firestore snapshot
          List<String> teacherNames = snapshot.data!.docs
              .map((doc) => doc['instructor'] as String)
              .toList();

          return GridView.count(
            crossAxisCount: 1,
            childAspectRatio: 3.0,
            children: List.generate(teacherNames.length, (index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewCourses(teacherNames[index]),
                    ),
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
          );
        },
      ),
    );
  }
}
