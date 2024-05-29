// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_attdence/Authentication/User&AdminLogin.dart';

// This is the main widget for the registration page
class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Sets the background color of the AppBar
        backgroundColor: Color.fromARGB(255, 107, 107, 245),
      ),
      // Sets the background color of the Scaffold
      backgroundColor: Color.fromARGB(255, 107, 107, 245),
      // The body of the Scaffold contains the RegisterForm widget
      body: RegisterForm(),
    );
  }
}

// This widget contains the registration form
class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

// This is the state class for RegisterForm
class _RegisterFormState extends State<RegisterForm> {
  // Controllers to manage the text input for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // FirebaseAuth instance to handle authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variables to store error messages for email and password fields
  String? _emailError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      // Column to arrange the widgets vertically
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'User Registration',
            // Styling for the header text
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30.0), // Adds space between the widgets
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: Colors.white), // Sets the text color
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle:
                  TextStyle(color: Colors.white), // Sets the label color
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white), // Border color when enabled
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white), // Border color when focused
              ),
              errorText: _emailError, // Displays error text if any
            ),
            keyboardType:
                TextInputType.emailAddress, // Keyboard type for email input
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          SizedBox(height: 20.0), // Adds space between the widgets
          TextFormField(
            controller: _passwordController,
            style: TextStyle(color: Colors.white), // Sets the text color
            obscureText: true, // Hides the text being entered
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle:
                  TextStyle(color: Colors.white), // Sets the label color
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white), // Border color when enabled
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white), // Border color when focused
              ),
              errorText: _passwordError, // Displays error text if any
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 30.0), // Adds space between the widgets
          SizedBox(
            width: double.infinity, // Makes the button full width
            child: ElevatedButton(
              onPressed: () {
                // Sets error messages if the fields are empty
                setState(() {
                  _emailError = _emailController.text.isEmpty
                      ? 'Please enter your email'
                      : null;
                  _passwordError = _passwordController.text.isEmpty
                      ? 'Please enter your password'
                      : null;
                });

                // Calls the registerUser function if there are no errors
                if (_emailError == null && _passwordError == null) {
                  registerUser();
                }
              },
              child: Text('Register',
                  style: TextStyle(fontSize: 18)), // Button text style
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Button background color
                padding: EdgeInsets.symmetric(vertical: 15.0), // Button padding
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(8.0), // Adds padding around the button
            child: SizedBox(
              width: double.infinity, // Makes the button full width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to LoginPage when the button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Login',
                    style: TextStyle(fontSize: 18)), // Button text style
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button background color
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0), // Button padding
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to register the user using FirebaseAuth
  void registerUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    try {
      // Tries to create a user with the provided email and password
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Shows a success dialog if the registration is successful
      _showMessageDialog(context, 'Success', 'User registered successfully!');
    } catch (e) {
      // Shows an error dialog if the registration fails
      _showMessageDialog(context, 'Error', 'Failed to register user: $e');
    }
  }

  // Function to show a message dialog
  Future<void> _showMessageDialog(
      BuildContext context, String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message), // Message content
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Disposes the controllers when the widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
