import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attdence/Operater%20pages/ViewCourses.dart';
import '../Home Page/OperaterHome.dart';

class Barcodescanner extends StatefulWidget {
  final String courseName;
  final String teacherName;

  const Barcodescanner(
      {Key? key, required this.courseName, required this.teacherName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BarcodescannerState();
}

class _BarcodescannerState extends State<Barcodescanner> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  late String _scannedBarcode = '';

  @override
  void initState() {
    super.initState();
    _scanBarcode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Text('Scanned Barcode: $_scannedBarcode'),
            ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcode == '-1') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to scan barcode.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        _scannedBarcode = barcode;
        _isLoading = false;
      });

      await _markAttendance(_scannedBarcode);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to scan barcode: $e'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _markAttendance(String scannedBarcode) async {
    try {
      final String currentDate = DateTime.now().toString();

      // Check if scannedBarcode matches any registration numbers displayed in previous page
      bool isValidRegNo = await _isValidRegNo(scannedBarcode);

      if (!isValidRegNo) {
        // Scanned registration number doesn't match any displayed registration numbers
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('This student is not registered for this course.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Reference to the attendance sub-collection for the specific course
      CollectionReference attendanceCollectionRef = _firestore
          .collection('Attendance')
          .doc(widget.courseName)
          .collection('Students RegNo');

      // Reference to the specific student's attendance document within the sub-collection
      DocumentReference attendanceDocRef =
          attendanceCollectionRef.doc(scannedBarcode);

      // Check if the attendance record already exists for this barcode
      DocumentSnapshot attendanceSnapshot = await attendanceDocRef.get();

      if (attendanceSnapshot.exists) {
        // Attendance record already exists, check if already marked as present
        bool isPresent =
            attendanceSnapshot.get('attendanceStatus') == 'Present';
        if (isPresent) {
          // Student already marked as present, show message and return
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Attendance already marked for this student.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ViewCourses(widget.teacherName),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
          return;
        } else {
          // Update the existing record to mark attendance as present
          await attendanceDocRef.update({
            'scannedTime': currentDate,
            'attendanceStatus': 'Present',
          });
        }
      } else {
        // Attendance record doesn't exist, create a new record
        Map<String, dynamic> attendanceRecord = {
          'date': currentDate,
          'courseName': widget.courseName,
          'teacherName': widget.teacherName,
          'scannedTime': currentDate,
          'attendanceStatus': 'Present',
        };

        // Save the attendance record to the sub-collection within the course document
        await attendanceDocRef.set(attendanceRecord);
      }

      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text(
              'Attendance marked successfully for registration number: $scannedBarcode'),
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
        ),
      );
    } catch (error) {
      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to mark attendance: $error'),
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
        ),
      );
    }
  }

  Future<bool> _isValidRegNo(String regNo) async {
    // Fetch registration numbers displayed in previous page
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Add Student for courses')
          .where('courses', arrayContains: widget.courseName)
          .get();

      List<String> studentRegNos =
          querySnapshot.docs.map((doc) => doc.id).toList();

      // Check if the scanned registration number exists in the list of displayed registration numbers
      return studentRegNos.contains(regNo);
    } catch (error) {
      print("Error fetching registration numbers: $error");
      return false; // Return false if there's an error
    }
  }
}
