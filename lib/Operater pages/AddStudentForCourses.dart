// Necessary imports for the Flutter application and Firestore integration.
// ignore_for_file: prefer_const_constructors, avoid_print, sized_box_for_whitespace, sort_child_properties_last, library_private_types_in_public_api, use_key_in_widget_constructors, file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Main widget for adding a student, extending StatefulWidget to maintain state.
class AddStudent extends StatefulWidget {
  @override
  _AddStudentState createState() => _AddStudentState();
}

// State class for the AddStudent widget.
class _AddStudentState extends State<AddStudent> {
  // Controller to manage the text input in the search field.
  TextEditingController searchController = TextEditingController();
  // Variable to hold the search term entered by the user.
  String searchTerm = '';
  // List to hold selected courses for a student.
  List<String> selectedCourses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Student',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, // Removes the back button.
        centerTitle: true, // Centers the title in the AppBar.
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
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
                            Colors.teal.shade50, // Sets the background color.
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(70.0),
                          borderSide: BorderSide.none, // Removes the border.
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchTerm =
                              value; // Updates the search term as the user types.
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Updates the search term when the search button is pressed.
                    setState(() {
                      searchTerm = searchController.text;
                    });
                  },
                  child: Text('Search'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white // Sets the button colors.
                      ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            // StreamBuilder to listen for real-time updates from Firestore.
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child:
                        CircularProgressIndicator(), // Shows a loading spinner.
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        'Error: ${snapshot.error}'), // Shows error message.
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                        'No students found'), // Shows message if no data is found.
                  );
                }

                // Filters the documents based on the search term.
                List<DocumentSnapshot> filteredDocs =
                    snapshot.data!.docs.where((doc) {
                  String regNo = doc['regNo'].toString().toLowerCase();
                  return regNo.contains(searchTerm.toLowerCase());
                }).toList();

                // Builds a list view of the filtered documents.
                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        filteredDocs[index]['regNo'].toString(),
                        style: TextStyle(fontSize: 16.0),
                      ),
                      onTap: () {
                        // Shows the course selection dialog when a student is tapped.
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

  // Function to show the course selection dialog.
  void _showCourseSelectionDialog(BuildContext context, String regNo) {
    // Temporary list to hold the courses selected in the dialog.
    List<String> tempSelectedCourses = List.from(selectedCourses);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // StatefulBuilder to maintain state inside the dialog.
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Select Courses',
                style: TextStyle(color: Colors.teal),
              ),
              content: Container(
                width: double.maxFinite,
                // StreamBuilder to listen for real-time updates from the courses collection.
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('courses')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child:
                            CircularProgressIndicator(), // Shows a loading spinner.
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'Error: ${snapshot.error}'), // Shows error message.
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                            'No courses found'), // Shows message if no data is found.
                      );
                    }
                    // Retrieves the list of all courses.
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
                    Navigator.of(context)
                        .pop(); // Closes the dialog without saving.
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Saves the selected courses to Firestore.
                    FirebaseFirestore.instance
                        .collection('Add Student for courses')
                        .doc(regNo) // Uses regNo as the document ID.
                        .set({
                      'courses': tempSelectedCourses,
                      'timestamp':
                          FieldValue.serverTimestamp(), // Adds a timestamp.
                    }).then((_) {
                      setState(() {
                        selectedCourses.clear(); // Clears the selections.
                      });
                      Navigator.pop(context); // Closes the dialog.
                      _showConfirmationMessage(
                          context); // Shows a confirmation message.
                    }).catchError((error) {
                      // Handles any errors.
                      print("Failed to save courses: $error");
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

  // Function to show a confirmation message after saving the courses.
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
                Navigator.of(context).pop(); // Closes the dialog.
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

  // Disposes the controller to free up resources when the widget is destroyed.
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
