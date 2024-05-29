// Import necessary packages and modules
// ignore_for_file: prefer_const_constructors, use_super_parameters, prefer_const_constructors_in_immutables, library_private_types_in_public_api, file_names

import 'dart:math'; // For generating random registration number
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore database operations
import 'package:flutter/material.dart'; // For Flutter UI components
import 'package:flutter/services.dart'; // For input formatters
import 'package:fluttertoast/fluttertoast.dart'; // For displaying toast messages
import 'package:student_attdence/Operater%20pages/barcodegenarater.dart'; // For navigating to BarcodeGenerator page

// Define a StatefulWidget for the Student Registration screen
class StuReg extends StatefulWidget {
  StuReg({Key? key}) : super(key: key);

  @override
  _StuRegState createState() => _StuRegState();
}

// State class for the StuReg widget
class _StuRegState extends State<StuReg> {
  // Define text controllers for form fields
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _regController = TextEditingController();
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void initState() {
    super.initState();
    _regController.text =
        generateRandomRegNo(); // Generate a random registration number
  }

  // Function to generate a random registration number
  String generateRandomRegNo() {
    final random = Random();
    int randomNumber = random.nextInt(9000) +
        1000; // Generate a random number between 1000 and 9999
    return 'anu_$randomNumber'; // Prefix "anu_" followed by the random number
  }

  // Function to upload data to Firestore
  uploadData() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> uploadData = {
        "name": _nameController.text,
        "email": _emailController.text,
        "address": _addressController.text,
        "Mobile": _mobileController.text,
        "regNo": _regController.text,
      };

      await DatabaseMethod()
          .addUserDetails(uploadData); // Add user details to Firestore
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Student Registration",
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
            "Student Registration",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey, // Assign the form key
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Name",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        //null means that the variable has not been assigned any value.
                        //The .isEmpty property checks if the string is empty.
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    // Address field
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: "Address",
                        prefixIcon: Icon(Icons.web),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
                    // Mobile number field
                    TextFormField(
                      controller: _mobileController,
                      decoration: InputDecoration(
                        hintText: "Mobile Number",
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        if (value.length != 10) {
                          return 'Mobile number should be 10 digits long';
                        }
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return 'Please enter a valid 10-digit mobile number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    SizedBox(height: 15.0),
                    // Registration number field (read-only)
                    TextFormField(
                      controller: _regController,
                      decoration: InputDecoration(
                        hintText: "Reg No",
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      enabled: false, // Disable editing
                    ),
                    SizedBox(height: 20.0),
                    // Submit button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          uploadData(); // Upload data to Firestore
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BarcodeGenerator(
                                name: _nameController.text,
                                email: _emailController.text,
                                Address: _addressController.text,
                                Mobile: _mobileController.text,
                                regNo: _regController.text,
                              ),
                            ),
                          );
                        } else {
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
                        backgroundColor: Colors
                            .teal, // Change the background color of the button
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15), // Adjust padding
                        // You can adjust horizontal and vertical padding values as needed
                      ),
                      child: Text("Generate Barcode"),
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

// Class to handle Firestore database operations
class DatabaseMethod {
  Future addUserDetails(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance.collection("Users").doc().set(
        userInfoMap); // Add user details to "Users" collection in Firestore
  }
}
