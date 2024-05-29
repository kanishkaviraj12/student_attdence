// Required imports for Flutter, Firestore, and other necessary packages
// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, use_super_parameters, prefer_const_constructors_in_immutables, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attdence/Home%20Page/OperaterHome.dart';
import 'dart:async';
import 'package:student_attdence/Operater%20pages/barcodescanner.dart';

// Stateful widget for viewing courses
class ViewCourses extends StatefulWidget {
  final String teacherName;

  ViewCourses(this.teacherName, {Key? key}) : super(key: key);

  @override
  State<ViewCourses> createState() => _ViewCoursesState();
}

class _ViewCoursesState extends State<ViewCourses> {
  List<Map<String, dynamic>> courses = []; // List to store courses
  Map<String, List<String>> courseStudents =
      {}; // Map to store students for each course
  late Timer _timer; // Timer for countdown
  int _totalSeconds =
      20; // Total countdown time in seconds (example 20 seconds) 60x60 = 3600 = 1h
  int _secondsRemaining = 0; // Remaining seconds in countdown

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _totalSeconds; // Initialize remaining seconds
    fetchCourses(); // Fetch courses when the widget is initialized
    startTimer(); // Start the countdown timer
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Function to start the countdown timer
  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (Timer timer) {
      if (_secondsRemaining == 0) {
        timer.cancel(); // Cancel the timer when it reaches 0
        markAbsentStudents(); // Mark absent students
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(), // Navigate to Home Page
          ),
        );
      } else {
        setState(() {
          _secondsRemaining--; // Decrease the remaining seconds
        });
      }
    });
  }

  // Function to fetch courses from Firestore
  void fetchCourses() {
    FirebaseFirestore.instance
        .collection('courses')
        .where('instructor',
            isEqualTo: widget.teacherName) // Filter by instructor
        .snapshots()
        .listen((querySnapshot) {
      List<Map<String, dynamic>> fetchedCourses = querySnapshot.docs.map((doc) {
        return {
          'courseName': doc['courseName'] as String,
          'fee': doc['fee'] as int
        };
      }).toList();

      //setState is a updating the state of a widget.
      setState(() {
        courses = fetchedCourses; // Update courses list
      });

      // Fetch students for each course
      for (var course in fetchedCourses) {
        FirebaseFirestore.instance
            .collection('Add Student for courses')
            .where('courses', arrayContains: course['courseName'])
            .snapshots()
            .listen((studentSnapshot) {
          List<String> studentRegNos =
              studentSnapshot.docs.map((doc) => doc.id).toList();

          //setState is a updating the state of a widget.
          setState(() {
            courseStudents[course['courseName']] =
                studentRegNos; // Update students list
          });
        });
      }
    });
  }

  // Function to mark absent students
  Future<void> markAbsentStudents() async {
    String currentDay =
        'day${DateTime.now().day}'; // Get current day, e.g., 'day27'

    for (var course in courses) {
      String courseName = course['courseName'];
      List<String>? students = courseStudents[courseName];

      if (students != null) {
        for (String student in students) {
          DocumentSnapshot attendanceSnapshot = await FirebaseFirestore.instance
              .collection('Attendance')
              .doc(courseName)
              .collection('Students RegNo')
              .doc(student)
              .get();

          final data = attendanceSnapshot.data() as Map<String, dynamic>?;

          if (data == null ||
              !data.containsKey(currentDay) ||
              data[currentDay]['attendanceStatus'] != 'Present') {
            // Mark student as absent if no record or not marked as present
            await FirebaseFirestore.instance
                .collection('Attendance')
                .doc(courseName)
                .collection('Students RegNo')
                .doc(student)
                .set({
              currentDay: {
                'scannedTime': '',
                'attendanceStatus': 'Absent',
              },
              'courseName': courseName,
              'teacherName': widget.teacherName,
            }, SetOptions(merge: true));
          }
        }
      }
    }
  }

  // Helper functions to format remaining time
  String getHours() {
    return '${(_secondsRemaining ~/ 3600).toString().padLeft(2, '0')}h';
  }

  String getMinutes() {
    return '${((_secondsRemaining % 3600) ~/ 60).toString().padLeft(2, '0')}m';
  }

  String getSeconds() {
    return '${(_secondsRemaining % 60).toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses by ${widget.teacherName}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: courses.length,
          itemBuilder: (BuildContext context, int index) {
            String courseName = courses[index]['courseName'];
            int fee = courses[index]['fee'];
            return GestureDetector(
              onTap: () {
                _timer.cancel(); // Stop the timer on tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Barcodescanner(
                      courseName: courseName,
                      teacherName: widget.teacherName,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.shade300,
                      Colors.teal.shade100,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(
                    courseName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...(courseStudents[courseName] ?? []).map((regNo) => Text(
                            'Student RegNo: $regNo',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Color.fromARGB(255, 54, 54, 54),
                            ),
                          )),
                      Text(
                        'Fee: \$${fee}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 54, 54, 54),
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward,
                      color: Color.fromARGB(255, 0, 17, 255)),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.teal,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Countdown: ${getHours()}:${getMinutes()}:${getSeconds()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
