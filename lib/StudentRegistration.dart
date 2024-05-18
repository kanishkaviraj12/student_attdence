// ignore_for_file: prefer_const_constructors, use_super_parameters, prefer_const_constructors_in_immutables, library_private_types_in_public_api, file_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:student_attdence/barcodegenarater.dart';
import 'package:student_attdence/database.dart';

class StuReg extends StatefulWidget {
  StuReg({Key? key}) : super(key: key);

  @override
  _StuRegState createState() => _StuRegState();
}

class _StuRegState extends State<StuReg> {
  final _websiteController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _regController = TextEditingController();

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
    Map<String, dynamic> uploadData = {
      "name": _nameController.text,
      "email": _emailController.text,
      "website": _websiteController.text,
      "regNo": _regController.text,
    };

    await DatabaseMethod().addUserDetails(uploadData);

    Fluttertoast.showToast(
        msg: "Data Stored Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Face",
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Student Registration",
            style: TextStyle(
              color: Color.fromARGB(255, 45, 44, 44),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: "Name"),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: "Email"),
                ),
                TextFormField(
                  controller: _websiteController,
                  decoration: InputDecoration(hintText: "Website"),
                ),
                TextFormField(
                  controller: _regController,
                  decoration: InputDecoration(hintText: "Reg No"),
                  enabled: false, // Disable editing
                ),
                ElevatedButton(
                  onPressed: () {
                    uploadData();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BarcodeGenerator(
                          name: _nameController.text,
                          email: _emailController.text,
                          website: _websiteController.text,
                          regNo: _regController.text,
                        ),
                      ),
                    );
                  },
                  child: Text("Generate Barcode"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
