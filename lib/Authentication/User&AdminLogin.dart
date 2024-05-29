// Import necessary Flutter and Firebase packages // ignore: use_key_in_widget_constructors
// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously, library_private_types_in_public_api, use_key_in_widget_constructors, unused_import, file_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_attdence/Operater%20pages/StudentRegistration.dart';
import 'package:student_attdence/Home%20Page/AdminHomePage.dart';
import 'package:student_attdence/Home%20Page/OperaterHome.dart';

// Define the LoginPage widget, which is a stateless widget
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 107, 107, 245), // Set the app bar color
      ),
      backgroundColor:
          Color.fromARGB(255, 107, 107, 245), // Set the background color
      body: LoginForm(), // Use the LoginForm widget as the body of the Scaffold
    );
  }
}

// Define the LoginForm widget, which is a stateful widget
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() =>
      _LoginFormState(); // Create the state for the widget
}

// Define the state class for LoginForm
class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController =
      TextEditingController(); // Controller for email input
  final TextEditingController _passwordController =
      TextEditingController(); // Controller for password input
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase authentication instance

  String? _emailError; // Variable to hold email error message
  String? _passwordError; // Variable to hold password error message

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0), // Add padding around the form
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center the form vertically
        children: <Widget>[
          Text(
            'User Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30.0), // Add space between elements
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorText: _emailError, // Display email error if present
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: _passwordController,
            style: TextStyle(color: Colors.white),
            obscureText: true, // Hide the password input
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorText: _passwordError, // Display password error if present
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 30.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  // Check if email and password fields are empty and set error messages
                  _emailError = _emailController.text.isEmpty
                      ? 'Please enter your email'
                      : null;
                  _passwordError = _passwordController.text.isEmpty
                      ? 'Please enter your password'
                      : null;
                });

                if (_emailError == null && _passwordError == null) {
                  loginUser(context); // Call loginUser if no errors
                }
              },
              child: Text('Login', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to handle user login
  void loginUser(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    try {
      // Attempt to sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the signed-in user is the admin
      if (userCredential.user!.email == 'admin@gmail.com') {
        // Show a success pop-up message for admin login
        _showMessageDialog(context, 'Success', 'Teacher logged in',
            isAdmin: true);
      } else {
        // Show a success pop-up message for regular user login
        _showMessageDialog(context, 'Success', 'User logged in successfully!',
            isAdmin: false);
      }
    } catch (e) {
      // Show an error pop-up message if login fails
      _showMessageDialog(context, 'Error', 'Failed to log in: $e',
          isAdmin: false);
    }
  }

  // Function to show a message dialog
  Future<void> _showMessageDialog(
      BuildContext context, String title, String message,
      {required bool isAdmin}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (title == 'Success') {
                  // Navigate to the appropriate page after successful login
                  if (isAdmin) {
                    // Navigate to admin page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminHome(),
                      ),
                    );
                  } else {
                    // Navigate to regular user page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Dispose controllers when the widget is disposed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
