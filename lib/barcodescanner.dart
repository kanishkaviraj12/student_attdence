import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attdence/markattendance.dart';

class Barcodescanner extends StatefulWidget {
  const Barcodescanner({super.key});

  @override
  State<StatefulWidget> createState() => _BarcodescannerState();
}

class _BarcodescannerState extends State<Barcodescanner> {
  final TextEditingController _textEditingController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _scanBarcode,
        tooltip: 'Scan',
        child: const Icon(Icons.camera),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: TextField(
                controller: _textEditingController,
                readOnly: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Scanned Text',
                  hintText: 'No text found',
                ),
                enableInteractiveSelection: true,
              ),
            ),
          ),
        ],
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
            builder: (context) => //MarkAttendancePage(),
                MarkAttendancePage(studentData: snapshot.docs.first.data()),
          ),
        );
      } else {
        // Barcode not found
        setState(() {
          _textEditingController.text = 'No data found for barcode: $barcode';
        });
      }

      // if (snapshot.docs.isNotEmpty) {
      //   // Barcode found, update text field with formatted data
      //   Map<String, dynamic> data = snapshot.docs.first.data();
      //   String formattedData = '';
      //   data.forEach((key, value) {
      //     formattedData += '$key: $value\n';
      //   });
      //   setState(() {
      //     _textEditingController.text = formattedData;
      //   });
      // } else {
      //   // Barcode not found
      //   setState(() {
      //     _textEditingController.text = 'No data found for barcode: $barcode';
      //   });
      // }
    } catch (e) {
      setState(() {
        _textEditingController.text = 'Error: $e';
      });
    }
  }
}
