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

      for (var document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        data['studentRegNo'] =
            document.id.toString(); // Convert DocumentID to String

        // Extract and flatten daily attendance records
        for (String key in data.keys) {
          if (key.startsWith('day')) {
            Map<String, dynamic> dailyData = data[key] as Map<String, dynamic>;
            dailyData['courseName'] = data['courseName'] ?? 'Unknown Course';
            dailyData['teacherName'] = data['teacherName'] ?? 'Unknown';
            dailyData['studentRegNo'] = data['studentRegNo'];
            dailyData['date'] = key; // Use the key (e.g., 'day27') as the date
            attendanceList.add(dailyData);
          }
        }
      }

      return attendanceList;
    } catch (error) {
      print("Error fetching attendance data: $error");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Attendance Report",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.teal.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 15.0),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(
            "Attendance Report",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
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
              Map<String, Map<String, List<Map<String, dynamic>>>> groupedData =
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
      ),
    );
  }

  // Group data by courseName and studentRegNo
  Map<String, Map<String, List<Map<String, dynamic>>>> _groupData(
      List<Map<String, dynamic>> data) {
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedData = {};

    for (var attendance in data) {
      String courseName = attendance['courseName'] ?? 'Unknown Course';
      String studentRegNo = attendance['studentRegNo'] ?? 'Unknown';

      if (!groupedData.containsKey(courseName)) {
        groupedData[courseName] = {};
      }
      if (!groupedData[courseName]!.containsKey(studentRegNo)) {
        groupedData[courseName]![studentRegNo] = [];
      }
      groupedData[courseName]![studentRegNo]!.add(attendance);
    }

    return groupedData;
  }

  List<DataRow> _buildDataRows(
      Map<String, Map<String, List<Map<String, dynamic>>>> groupedData) {
    List<DataRow> rows = [];

    groupedData.forEach((courseName, studentMap) {
      bool isFirstCourseRow = true;

      studentMap.forEach((studentRegNo, attendances) {
        bool isFirstStudentRow = true;

        for (var attendance in attendances) {
          String attendanceStatus = attendance['attendanceStatus'] ?? 'Unknown';
          String date = attendance['date'] ?? 'Unknown';
          String teacherName = attendance['teacherName'] ?? 'Unknown';
          String scannedTime = attendance['scannedTime'] ?? 'Unknown';

          Color? textColor;
          if (attendanceStatus == 'Present') {
            textColor = Colors.green;
          } else if (attendanceStatus == 'Absent') {
            textColor = Colors.red;
          }

          rows.add(DataRow(cells: [
            isFirstCourseRow
                ? DataCell(Text(courseName,
                    style: TextStyle(fontWeight: FontWeight.bold)))
                : DataCell(Text('')),
            isFirstStudentRow
                ? DataCell(Text(studentRegNo))
                : DataCell(Text('')),
            DataCell(Text(attendanceStatus,
                style: textColor != null ? TextStyle(color: textColor) : null)),
            DataCell(Text(date)),
            DataCell(Text(teacherName)),
            DataCell(Text(scannedTime)),
          ]));

          isFirstCourseRow = false;
          isFirstStudentRow = false;
        }
      });
    });

    return rows;
  }
}
