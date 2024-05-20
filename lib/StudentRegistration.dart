// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_super_parameters, prefer_const_constructors_in_immutables, file_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:student_attdence/barcodegenarater.dart';
import 'package:student_attdence/database.dart';

class StuReg extends StatefulWidget {
  StuReg({Key? key}) : super(key: key);

  @override
  _StuRegState createState() => _StuRegState();
}

class _StuRegState extends State<StuReg> {
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _regController = TextEditingController();
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void initState() {
    super.initState();
    _regController.text = generateRandomRegNo();
  }

  String generateRandomRegNo() {
    final random = Random();
    int randomNumber = random.nextInt(9000) +
        1000; // Generate a random number between 1000 and 9999
    return 'anu_$randomNumber'; // Prefix "anu_" followed by the random number
  }

  uploadData() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> uploadData = {
        "name": _nameController.text,
        "email": _emailController.text,
        "address": _addressController.text,
        "Mobile": _mobileController.text,
        "regNo": _regController.text,
      };

      await DatabaseMethod().addUserDetails(uploadData);
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
            style: TextStyle(color: Colors.white),
          ),
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
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Name",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
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
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: "Address",
                        prefixIcon: Icon(Icons.web),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.0),
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
                    TextFormField(
                      controller: _regController,
                      decoration: InputDecoration(
                        hintText: "Reg No",
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      enabled: false, // Disable editing
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          uploadData();
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
