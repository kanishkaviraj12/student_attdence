// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_function_literals_in_foreach_calls, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceReport extends StatefulWidget {
  @override
  _AttendanceReportState createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  late Future<List<Map<String, dynamic>>> _attendanceData;

  @override
  void initState() {
    super.initState();
    _attendanceData = fetchAttendanceData();
  }

  Future<List<Map<String, dynamic>>> fetchAttendanceData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('Students RegNo')
          .get();

      List<Map<String, dynamic>> attendanceList = [];

      querySnapshot.docs.forEach((document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        data['studentRegNo'] = document.id; // Include registration number
        attendanceList.add(data);
      });

      return attendanceList;
    } catch (error) {
      print("Error fetching attendance data: $error");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Report'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _attendanceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No attendance data available'));
          } else {
            Map<String, List<Map<String, dynamic>>> groupedData =
                _groupData(snapshot.data!);

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  columns: [
                    DataColumn(label: Text('Course Name')),
                    DataColumn(label: Text('Student RegNo')),
                    DataColumn(label: Text('Attendance Status')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Teacher Name')),
                    DataColumn(label: Text('Scanned Time')),
                  ],
                  rows: _buildDataRows(groupedData),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupData(
      List<Map<String, dynamic>> data) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    data.forEach((attendance) {
      String courseName = attendance['courseName'];
      if (!groupedData.containsKey(courseName)) {
        groupedData[courseName] = [];
      }
      groupedData[courseName]!.add(attendance);
    });

    return groupedData;
  }

  List<DataRow> _buildDataRows(
      Map<String, List<Map<String, dynamic>>> groupedData) {
    List<DataRow> rows = [];

    groupedData.forEach((courseName, attendances) {
      // Display course name only in the first row
      bool isFirstRow = true;
      attendances.forEach((attendance) {
        // Determine font color based on attendance status
        Color textColor = attendance['attendanceStatus'] == 'Present'
            ? Colors.green
            : Colors.red;

        rows.add(DataRow(cells: [
          isFirstRow
              ? DataCell(
                  Text(courseName,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )
              : DataCell(Text('')),
          DataCell(
            Text(attendance['studentRegNo'],
                style: TextStyle(color: textColor)),
          ),
          DataCell(
            Text(attendance['attendanceStatus'],
                style: TextStyle(color: textColor)),
          ),
          DataCell(
            Text(attendance['date'], style: TextStyle(color: textColor)),
          ),
          DataCell(
            Text(attendance['teacherName'], style: TextStyle(color: textColor)),
          ),
          DataCell(
            Text(attendance['scannedTime'], style: TextStyle(color: textColor)),
          ),
        ]));
        isFirstRow = false;
      });
    });

    return rows;
  }
}
