// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attdence/Operater%20pages/ViewCourses.dart';

// Define a stateless widget called ViewTeachers
class ViewTeachers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Define the AppBar
      appBar: AppBar(
        title: Text(
          'Teachers',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 4.0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove the back button
      ),
      // Define the body of the Scaffold with a StreamBuilder.This is particularly useful for real-time data updates
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          // Show a loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          // Display an error message if there's an error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            );
          }
          // Show a message if no data is found
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No teachers found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            );
          }

          // Extract teacher names from Firestore snapshot
          List<String> teacherNames = snapshot.data!.docs
              .map((doc) => doc['instructor'] as String)
              .toList();

          return Padding(
            padding: EdgeInsets.all(20.0),
            // Use GridView to display teacher names
            child: GridView.count(
              crossAxisCount: 1, // One item per row
              childAspectRatio: 3.0, // Height to width ratio of each item
              children: List.generate(teacherNames.length, (index) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to ViewCourses when a teacher card is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewCourses(teacherNames[index]),
                      ),
                    );
                  },
                  // Define the card for each teacher
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade200, Colors.teal.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person, // Teacher icon
                              color: Colors.white,
                            ),
                            SizedBox(
                                width: 10), // Spacing between icon and text
                            Text(
                              teacherNames[index],
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
