// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MarkAttendancePage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  MarkAttendancePage({super.key, required this.studentData});

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
        child: _isSaving
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _saveAttendanceData,
                child: Text('Save Attendance'),
              ),
      ),
    );
  }

  void _saveAttendanceData() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final String barcode = widget.studentData['regNo'];
      final String currentDate = DateTime.now().toString();

      Map<String, dynamic> attendanceRecord = {
        'date': currentDate,
        'scannedTime': currentDate,
        'attendanceStatus':
            'Present', // Assuming all students are present by default
      };

      // Save the attendance record to Firestore under the 'Attendance' collection with regNo as document ID
      await _firestore
          .collection('Attendance')
          .doc(barcode)
          .set(attendanceRecord);

      // Show a snackbar to indicate successful save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance saved successfully'),
        ),
      );
    } catch (error) {
      // Show a snackbar for any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save attendance: $error'),
        ),
      );
    } finally {
      // Reset the saving state
      setState(() {
        _isSaving = false;
      });
    }
  }
}




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class MarkAttendancePage extends StatefulWidget {
//   @override
//   _MarkAttendancePageState createState() => _MarkAttendancePageState();
// }

// class _MarkAttendancePageState extends State<MarkAttendancePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _isSaving = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Mark Attendance'),
//       ),
//       body: Center(
//         child: _isSaving
//             ? CircularProgressIndicator()
//             : ElevatedButton(
//                 onPressed: _saveAttendanceData,
//                 child: Text('Save Attendance'),
//               ),
//       ),
//     );
//   }

//   void _saveAttendanceData() async {
//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       // Fetch all documents from the 'Users' collection
//       QuerySnapshot usersSnapshot = await _firestore.collection('Users').get();

//       // Extract 'regNo' from each document and save it to the 'Attendance' collection
//       for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
//         // Perform null checks before accessing document data and 'regNo' field
//         if (userDoc.exists && userDoc.data() != null) {
//           dynamic userData = userDoc.data();
//           if (userData.containsKey('regNo') && userData['regNo'] != null) {
//             String regNo = userData['regNo'];
//             // Save 'regNo' to the 'Attendance' collection
//             await _firestore
//                 .collection('Attendance')
//                 .doc(regNo)
//                 .set({'regNo': regNo});
//           }
//         }
//       }

//       // Show a snackbar to indicate successful save
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Attendance records saved successfully'),
//         ),
//       );
//     } catch (error) {
//       // Show a snackbar for any errors
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to save attendance records: $error'),
//         ),
//       );
//     } finally {
//       // Reset the saving state
//       setState(() {
//         _isSaving = false;
//       });
//     }
//   }
// }
