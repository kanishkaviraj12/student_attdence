// Import necessary packages and files
// ignore_for_file: avoid_print, prefer_const_constructors, use_build_context_synchronously, use_super_parameters, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Home Page/OperaterHome.dart'; // Assuming this is the correct path to OperaterHome.dart

// Define a StatefulWidget for the BarcodeScanner
class Barcodescanner extends StatefulWidget {
  final String courseName;
  final String teacherName;

  // Constructor to initialize courseName and teacherName
  Barcodescanner(
      {Key? key, required this.courseName, required this.teacherName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BarcodescannerState();
}

// Define the state for the BarcodeScanner
class _BarcodescannerState extends State<Barcodescanner> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true; // Initial loading state
  late String _scannedBarcode = ''; // Initially empty barcode string

  @override
  void initState() {
    super.initState();
    _scanBarcode(); // Start scanning barcode when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'), // AppBar title
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Show loading indicator while scanning
            )
          : Center(
              child: Text(
                  'Scanned Barcode: $_scannedBarcode'), // Show scanned barcode when available
            ),
    );
  }

  // Function to scan barcode asynchronously
  Future<void> _scanBarcode() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Color of the scan overlay
        'Cancel', // Cancel button text
        true, // Use flash
        ScanMode.BARCODE, // Scan mode
      );

      // Handle if barcode scanning is cancelled
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
                  Navigator.of(context).pop(); // Dismiss dialog and go back
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Update UI with scanned barcode and mark loading as false
      setState(() {
        _scannedBarcode = barcode;
        _isLoading = false;
      });

      // Mark attendance after successful scanning
      await _markAttendance(_scannedBarcode);
    } catch (e) {
      // Handle any errors occurred during barcode scanning
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

  // Function to mark attendance based on scanned barcode
  //the parameter scannedBarcode in the _markAttendance method is not nullable,
  Future<void> _markAttendance(String scannedBarcode) async {
    try {
      final DateTime now = DateTime.now();
      final String currentDate = now.toIso8601String();
      final String currentDay = 'day${now.day}'; // Generate current day string

      // Check if the scanned barcode matches any registration numbers displayed in the previous page
      bool isValidRegNo = await _isValidRegNo(scannedBarcode);

      // If the scanned registration number is invalid, show error dialog
      if (!isValidRegNo) {
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

      // Safely cast the data to a Map<String, dynamic>
      final data = attendanceSnapshot.data() as Map<String, dynamic>?;

      // If attendance is already marked for the current day, show error dialog
      if (data != null && data.containsKey(currentDay)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Attendance already marked for today.'),
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
        return;
      }

      // Update the existing record to mark attendance for the specific day or create a new record
      await attendanceDocRef.set({
        currentDay: {
          'scannedTime': currentDate,
          'attendanceStatus': 'Present',
        },
        'courseName': widget.courseName,
        'teacherName': widget.teacherName,
      }, SetOptions(merge: true));

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
      // Show error message if marking attendance fails
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

  // Function to check if the scanned registration number is valid
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
