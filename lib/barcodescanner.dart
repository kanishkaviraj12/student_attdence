// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attdence/markattendance.dart';

class Barcodescanner extends StatefulWidget {
  const Barcodescanner({super.key, required String courseName});

  @override
  State<StatefulWidget> createState() => _BarcodescannerState();
}

class _BarcodescannerState extends State<Barcodescanner> {
  final TextEditingController _textEditingController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

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
          : Column(),
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

      // Search barcode value in Firestore
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('Users')
          .where('regNo', isEqualTo: barcode)
          .get();

      print('Number of documents returned: ${snapshot.docs.length}');
      print('Documents: ${snapshot.docs}');

      if (snapshot.docs.isNotEmpty) {
        // Navigate to attendance marking page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MarkAttendancePage(studentData: snapshot.docs.first.data()),
          ),
        );
      } else {
        // Show error message popup
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('No data found for barcode: $barcode'),
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
      }
    } catch (e) {
      setState(() {
        _textEditingController.text = 'Error: $e';
        _isLoading = false; // Set loading to false as scanning is completed
      });
    }
  }
}
