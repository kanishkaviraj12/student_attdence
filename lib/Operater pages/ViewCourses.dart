// ignore_for_file: use_super_parameters, prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_print, unnecessary_brace_in_string_interps, prefer_final_fields, file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attdence/Home%20Page/OperaterHome.dart';
import 'dart:async';

import 'package:student_attdence/Operater%20pages/barcodescanner.dart';

class ViewCourses extends StatefulWidget {
  final String teacherName;

  ViewCourses(this.teacherName, {Key? key}) : super(key: key);

  @override
  State<ViewCourses> createState() => _ViewCoursesState();
}

class _ViewCoursesState extends State<ViewCourses> {
  List<Map<String, dynamic>> courses = [];
  Map<String, List<String>> courseStudents = {};
  late Timer _timer;
  int _totalSeconds = 20; // For example, 10 seconds 60x60=1h
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _totalSeconds;
    fetchCourses();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (Timer timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        markAbsentStudents();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ),
        );
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void fetchCourses() {
    FirebaseFirestore.instance
        .collection('courses')
        .where('instructor', isEqualTo: widget.teacherName)
        .snapshots()
        .listen((querySnapshot) {
      List<Map<String, dynamic>> fetchedCourses = querySnapshot.docs.map((doc) {
        return {
          'courseName': doc['courseName'] as String,
          'fee': doc['fee'] as int
        };
      }).toList();

      setState(() {
        courses = fetchedCourses;
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

          setState(() {
            courseStudents[course['courseName']] = studentRegNos;
          });
        });
      }
    });
  }

  Future<void> markAbsentStudents() async {
    String currentDay =
        'day${DateTime.now().day}'; // Automatically set current day, e.g., 'day27'

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

          // Safely cast the data to a Map<String, dynamic>
          final data = attendanceSnapshot.data() as Map<String, dynamic>?;

          if (data == null ||
              !data.containsKey(currentDay) ||
              data[currentDay]['attendanceStatus'] != 'Present') {
            // Mark the student as absent if no attendance record exists for the specific day or if not marked as present
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
                _timer.cancel(); // Stop the timer
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
