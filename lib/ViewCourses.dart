import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attdence/newhome.dart';
import 'barcodescanner.dart';

class ViewCourses extends StatefulWidget {
  final String teacherName;

  ViewCourses(this.teacherName, {Key? key}) : super(key: key);

  @override
  State<ViewCourses> createState() => _ViewCoursesState();
}

class _ViewCoursesState extends State<ViewCourses> {
  List<String> courses = [];
  Map<String, List<String>> courseStudents = {};
  late Timer _timer;
  int _totalSeconds = 10; // For example, 10 seconds
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

      // Fetch students for each course
      for (String course in fetchedCourses) {
        QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
            .collection('Add Student for courses')
            .where('courses', arrayContains: course)
            .get();

        List<String> studentRegNos =
            studentSnapshot.docs.map((doc) => doc.id).toList();

        setState(() {
          courseStudents[course] = studentRegNos;
        });
      }
    } catch (error) {
      print("Error fetching courses: $error");
    }
  }

  Future<void> markAbsentStudents() async {
    String currentDate = DateTime.now().toIso8601String();

    for (String course in courses) {
      List<String>? students = courseStudents[course];

      if (students != null) {
        for (String student in students) {
          DocumentSnapshot attendanceSnapshot = await FirebaseFirestore.instance
              .collection('Attendance')
              .doc(course)
              .collection('Students RegNo')
              .doc(student)
              .get();

          if (!attendanceSnapshot.exists ||
              attendanceSnapshot.get('attendanceStatus') != 'Present') {
            // Mark the student as absent if no attendance record exists or if not marked as present
            await FirebaseFirestore.instance
                .collection('Attendance')
                .doc(course)
                .collection('Students RegNo')
                .doc(student)
                .set({
              'date': currentDate,
              'courseName': course,
              'teacherName': widget.teacherName,
              'scannedTime': '',
              'attendanceStatus': 'Absent',
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
                  //return CircularProgressIndicator();
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
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Countdown: ${getHours()}:${getMinutes()}:${getSeconds()}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timeout Page'),
      ),
      body: Center(
        child: Text('Timeout reached!'),
      ),
    );
  }
}
