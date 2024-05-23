// ignore_for_file: use_key_in_widget_constructors, file_names, library_private_types_in_public_api, prefer_const_constructors, sort_child_properties_last, avoid_print, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudent extends StatefulWidget {
  @override
  _AddStudentState createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  TextEditingController searchController = TextEditingController();
  String searchTerm = '';
  List<String> selectedCourses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Student',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, //remove backbutton
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Enter Registration Number',
                        filled: true,
                        fillColor:
                            Colors.teal.shade50, // Use registration page color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(70.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchTerm = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Perform search action
                    setState(() {
                      searchTerm = searchController.text;
                    });
                  },
                  child: Text('Search'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor:
                          Colors.white // Use registration page color
                      ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No students found'),
                  );
                }

                // Filter documents based on search term
                List<DocumentSnapshot> filteredDocs =
                    snapshot.data!.docs.where((doc) {
                  String regNo = doc['regNo'].toString().toLowerCase();
                  return regNo.contains(searchTerm.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        filteredDocs[index]['regNo'].toString(),
                        style: TextStyle(fontSize: 16.0),
                      ),
                      onTap: () {
                        _showCourseSelectionDialog(
                            context, filteredDocs[index]['regNo'].toString());
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCourseSelectionDialog(BuildContext context, String regNo) {
    List<String> tempSelectedCourses = List.from(selectedCourses);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Select Courses',
                style: TextStyle(color: Colors.teal),
              ),
              content: Container(
                width: double.maxFinite,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('courses')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('No courses found'),
                      );
                    }
                    List<String> allCourses = snapshot.data!.docs
                        .map((doc) => doc['courseName'].toString())
                        .toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: allCourses.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          title: Text(allCourses[index]),
                          value:
                              tempSelectedCourses.contains(allCourses[index]),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                tempSelectedCourses.add(allCourses[index]);
                              } else {
                                tempSelectedCourses.remove(allCourses[index]);
                              }
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Save selected courses to Firestore for the student
                    FirebaseFirestore.instance
                        .collection('Add Student for courses')
                        .doc(regNo) // Use regNo as document ID
                        .set({
                      'courses': tempSelectedCourses,
                      'timestamp':
                          FieldValue.serverTimestamp(), // Add timestamp
                    }).then((_) {
                      setState(() {
                        selectedCourses.clear(); // Clear selections
                      });
                      Navigator.pop(context); // Go back to previous screen
                      _showConfirmationMessage(
                          context); // Show confirmation message
                    }).catchError((error) {
                      // Handle error if any
                      print("Failed to save courses: $error");
                      // You can show a snackbar or dialog to inform the user
                    });
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmationMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Courses Saved',
            style: TextStyle(color: Colors.teal),
          ),
          content: Text(
            'Selected courses have been saved successfully!',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.teal),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
