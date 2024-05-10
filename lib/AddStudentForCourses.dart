import 'package:flutter/material.dart';

class StudentSearchScreen extends StatefulWidget {
  @override
  _StudentSearchScreenState createState() => _StudentSearchScreenState();
}

class _StudentSearchScreenState extends State<StudentSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  Student? _selectedStudent;
  List<Course> _selectedCourses = [];

  // Sample student data
  List<Student> _students = [
    Student(regNumber: '123', name: 'John Doe', department: 'Computer Science'),
    Student(
        regNumber: '456',
        name: 'Jane Smith',
        department: 'Electrical Engineering'),
  ];

  // Sample course data
  List<Course> _courses = [
    Course(name: 'Mathematics'),
    Course(name: 'Physics'),
    Course(name: 'Chemistry'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Registration Number',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _searchStudent,
            child: Text('Search'),
          ),
          if (_selectedStudent != null) ...[
            SizedBox(height: 20),
            Text('Student Details:'),
            Text('Name: ${_selectedStudent!.name}'),
            Text('Registration Number: ${_selectedStudent!.regNumber}'),
            Text('Department: ${_selectedStudent!.department}'),
            SizedBox(height: 20),
            Text('Select Courses:'),
            Column(
              children: _courses.map((course) {
                return CheckboxListTile(
                  title: Text(course.name),
                  value: _selectedCourses.contains(course),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        _selectedCourses.add(course);
                      } else {
                        _selectedCourses.remove(course);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                // Add your logic to add selected courses to student
              },
              child: Text('Add Courses'),
            ),
          ],
        ],
      ),
    );
  }

  // Method to search for a student by registration number
  void _searchStudent() {
    String searchText = _searchController.text.trim();

    // Flag to indicate if the student is found
    bool studentFound = false;

    // Iterate through the list of students to find a match
    for (Student student in _students) {
      if (student.regNumber == searchText) {
        setState(() {
          _selectedStudent = student;
        });
        studentFound = true;
        break;
      }
    }

    // If student is not found, reset the selected student
    if (!studentFound) {
      setState(() {
        _selectedStudent = null;
      });
    }
  }
}

// Sample data for demonstration
class Student {
  final String regNumber;
  final String name;
  final String department;

  Student({
    required this.regNumber,
    required this.name,
    required this.department,
  });
}

class Course {
  final String name;

  Course({required this.name});
}
