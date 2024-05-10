// ignore_for_file: prefer_const_constructors, use_super_parameters, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attdence/newhome.dart';

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
    // Call the barcode scanning method when the page loads
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
            ) // Display a loading indicator while scanning
          : Center(
              child: Text('Scanned Barcode: $_scannedBarcode'),
            ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // red color for scan button
        'Cancel', // cancel button text
        true, // show flash icon
        ScanMode.BARCODE, // scan mode
      );

      print('Scanned Barcode: $barcode');

      if (barcode == '-1') {
        // Handle failed barcode scanning
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to scan barcode.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); //one step back
                  Navigator.of(context).pop(); //one step back
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
        _isLoading = false; // Set loading to false as scanning is completed
      });

      // Mark attendance
      await _markAttendance(_scannedBarcode);
    } catch (e) {
      setState(() {
        _isLoading = false; // Set loading to false as scanning is completed
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to scan barcode: $e'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); //one step back
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

      Map<String, dynamic> attendanceRecord = {
        'date': currentDate,
        'courseName': widget.courseName,
        'teacherName': widget.teacherName,
        'scannedTime': currentDate,
        'attendanceStatus': 'Present',
      };

      // Save the attendance record to Firestore with student registration number as document ID
      await _firestore
          .collection('Attendance')
          .doc(scannedBarcode)
          .set(attendanceRecord);

      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text(
              'Attendance marked successfully for barcode: $scannedBarcode'),
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
}
