// Required Flutter and Firebase imports
// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Define a StatefulWidget for adding courses
class AddCourses extends StatefulWidget {
  AddCourses({super.key});

  @override
  State<AddCourses> createState() => _AddCoursesState();
}

// The state class for AddCourses
class _AddCoursesState extends State<AddCourses> {
  // Controllers for managing input fields
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

  // Key for the form to validate input
  //GlobalKey<FormState> is a class provided by the Flutter framework.
  final _formKey = GlobalKey<FormState>();

  // Loading state to show a progress indicator
  bool _isLoading = false;

  // Method to save course details to Firestore
  Future<void> saveCourseToFirestore({
    required String courseName, // named parameters for the method.
    required String instructor,
    required int fee,
  }) async {
    try {
      // Add course details to the 'courses' collection in Firestore
      await FirebaseFirestore.instance.collection('courses').add({
        'courseName': courseName,
        'instructor': instructor,
        'fee': fee,
      });
      // Show success toast
      Fluttertoast.showToast(
          msg: "Course added successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      // Show error toast if there's an exception
      Fluttertoast.showToast(
          msg: "Error adding course: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override //a method in a subclass is overriding a method of its superclass.
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Add Course',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.teal.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
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
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 15.0),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(
            'Add Course',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enter Course Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _courseNameController,
                      decoration: InputDecoration(
                        hintText: 'Course Name',
                        prefixIcon: Icon(Icons.book),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the course name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    TextFormField(
                      controller: _instructorController,
                      decoration: InputDecoration(
                        hintText: 'Instructor',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the instructor name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    TextFormField(
                      controller: _feeController,
                      decoration: InputDecoration(
                        hintText: 'Class Fee',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the class fee';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Validate the form and save to Firestore
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  saveCourseToFirestore(
                                    courseName: _courseNameController.text,
                                    instructor: _instructorController.text,
                                    fee: int.parse(_feeController.text),
                                  ).then((_) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  });
                                } else {
                                  // Show error toast if form validation fails
                                  Fluttertoast.showToast(
                                      msg: "Please fix errors in the form.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                              ),
                              child: Text(
                                'Save',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
