// Import necessary Flutter material package
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:student_attdence/Operater%20pages/AddStudentForCourses.dart';
import 'package:student_attdence/Operater%20pages/ViewTeachers.dart';
import 'package:student_attdence/Operater%20pages/StudentRegistration.dart';

// Define the main home page as a StatefulWidget
class MyHomePage extends StatefulWidget {
  MyHomePage(
      {super.key}); // Constructor with key. constructer are used to create instance of a class

  @override
  _MyHomePageState createState() =>
      _MyHomePageState(); // Create state for the widget
}

// State class for the MyHomePage widget
class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex =
      0; // Index to keep track of the selected bottom navigation item

  // List of widgets to display based on the selected index
  static final List<Widget> _widgetOptions = <Widget>[
    ViewTeachers(),
    StuReg(),
    AddStudent(),
  ];

  // Method to update the selected index when a bottom navigation item is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions
            .elementAt(_selectedIndex), // Display the selected page
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(66, 255, 0, 234), // Shadow color
              spreadRadius: 0, // Spread radius
              blurRadius: 10, // Blur radius
              offset: Offset(0, -3), // Offset in x and y direction
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Fixed bottom navigation bar
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home), // Icon for Home tab
              label: 'Home', // Label for Home tab
            ),
            BottomNavigationBarItem(
              icon:
                  Icon(Icons.app_registration_rounded), // Icon for Register tab
              label: 'Register', // Label for Register tab
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined), // Icon for Add Student tab
              label: 'Add Student', // Label for Add Student tab
            ),
          ],
          currentIndex: _selectedIndex, // Current selected index
          selectedItemColor:
              Color.fromARGB(255, 202, 0, 135), // Color for selected item
          unselectedItemColor: Colors.grey, // Color for unselected items
          onTap: _onItemTapped, // On tap handler
          selectedFontSize: 16, // Font size for selected item label
          unselectedFontSize: 14, // Font size for unselected item label
          selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold), // Style for selected item label
          unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal), // Style for unselected item label
        ),
      ),
    );
  }
}
