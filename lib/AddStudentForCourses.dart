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
        title: Text('Search Student'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Enter Registration Number',
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchTerm = value;
                      });
                    },
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Courses'),
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
                          value: selectedCourses.contains(allCourses[index]),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                selectedCourses.add(allCourses[index]);
                              } else {
                                selectedCourses.remove(allCourses[index]);
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
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Save selected courses to Firestore for the student
                    FirebaseFirestore.instance
                        .collection('Add Student for courses')
                        .doc(regNo) // Use regNo as document ID
                        .set({
                      'courses': selectedCourses,
                    }).then((_) {
                      setState(() {
                        selectedCourses.clear(); // Clear selections
                      });
                      Navigator.pop(context); // Go back to previous screen
                    }).catchError((error) {
                      // Handle error if any
                      print("Failed to save courses: $error");
                      // You can show a snackbar or dialog to inform the user
                    });
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
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
