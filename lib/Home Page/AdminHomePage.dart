// Ignore specific lint rules for this file
// ignore_for_file: prefer_const_constructors_in_immutables, file_names, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:student_attdence/Admin%20Pages/AddCourses.dart';
import 'package:student_attdence/Admin%20Pages/AttendanceReport.dart';

// Define the AdminHome widget as a stateful widget
class AdminHome extends StatefulWidget {
  AdminHome(
      {super.key}); // Constructor with key. constructer are used to create instance of a class

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

// State class for AdminHome
class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0; // Track the selected index of the BottomNavigationBar

  // List of widgets that correspond to each tab
  static final List<Widget> _widgetOptions = <Widget>[
    AddCourses(),
    AttendanceReport(),
  ];

  // Method to handle tapping on a BottomNavigationBar item
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index and refresh the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions
            .elementAt(_selectedIndex), // Display the selected widget
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(66, 255, 0, 234), // Pink shadow color
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, -3), // Shadow offset
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Fixed navigation bar
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person_search_rounded), // Icon for "Add Courses"
              label: 'Add Courses', // Label for "Add Courses"
            ),
            BottomNavigationBarItem(
              icon: Icon(
                  Icons.library_books_rounded), // Icon for "Attendance Report"
              label: 'Attendance Report', // Label for "Attendance Report"
            ),
          ],
          currentIndex: _selectedIndex, // Currently selected index
          selectedItemColor:
              Color.fromARGB(255, 202, 0, 135), // Pink color for selected item
          unselectedItemColor: Colors.grey, // Grey color for unselected items
          onTap: _onItemTapped, // Call _onItemTapped when an item is tapped
          selectedFontSize: 16, // Font size for selected item
          unselectedFontSize: 14, // Font size for unselected items
          selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold), // Bold text for selected item
          unselectedLabelStyle: TextStyle(
              fontWeight:
                  FontWeight.normal), // Normal text for unselected items
        ),
      ),
    );
  }
}
