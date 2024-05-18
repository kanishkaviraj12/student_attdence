// ignore_for_file: unused_import, prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, sort_child_properties_last, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_attdence/StudentRegistration.dart';
import 'package:student_attdence/Home%20Page/AdminHomePage.dart';
import 'package:student_attdence/Home%20Page/OperaterHome.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 107, 107, 245),
      ),
      backgroundColor: Color.fromARGB(255, 107, 107, 245),
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _emailError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'User Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30.0),
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
              errorText: _emailError,
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
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorText: _passwordError,
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
                  _emailError = _emailController.text.isEmpty
                      ? 'Please enter your email'
                      : null;
                  _passwordError = _passwordController.text.isEmpty
                      ? 'Please enter your password'
                      : null;
                });

                if (_emailError == null && _passwordError == null) {
                  loginUser(context); // Pass the context to loginUser
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

  void loginUser(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    try {
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
      _showMessageDialog(context, 'Error', 'Failed to log in: $e',
          isAdmin: false);
    }
  }

  Future<void> _showMessageDialog(
      BuildContext context, String title, String message,
      {required bool isAdmin}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                        builder: (context) => TeacherHome(),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
