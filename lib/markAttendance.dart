import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attdence/newhome.dart';

class MarkAttendancePage extends StatefulWidget {
  final String teacherName;
  final String courseName;

  MarkAttendancePage(
      {required this.teacherName, required this.courseName, Key? key})
      : super(key: key);

  @override
  _MarkAttendancePageState createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance'),
      ),
      body: Center(
        child: _isSaving ? CircularProgressIndicator() : Text(''),
      ),
    );
  }

  void _saveAttendanceData() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final String currentDate = DateTime.now().toString();

      Map<String, dynamic> attendanceRecord = {
        'date': currentDate,
        'teacherName': widget.teacherName,
        'courseName': widget.courseName,
        'scannedTime': currentDate,
        'attendanceStatus':
            'Present', // Assuming all students are present by default
      };

      // Save the attendance record to Firestore
      await _firestore.collection('Attendance').add(attendanceRecord);

      // Show a dialog to indicate successful save
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Attendance saved successfully'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (BuildContext context) => MyHomePage(),
                    ),
                    (route) => false,
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Show a dialog for any errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to save attendance: $error'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (BuildContext context) => MyHomePage(),
                    ),
                    (route) => false,
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      // Reset the saving state
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _saveAttendanceData();
  }
}
