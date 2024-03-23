// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:student_attdence/barcodegenarater.dart';
import 'package:student_attdence/barcodescanner.dart';
import 'package:student_attdence/database.dart';
import 'package:student_attdence/qrcodegenerater.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  uploadData() async {
    Map<String, dynamic> uploadData = {
      "name": _nameController.text,
      "email": _emailController.text,
      "website": _websiteController.text,
    };

    await DatabaseMethod().addUserDetails(uploadData);

    Fluttertoast.showToast(
        msg: "Data Stored Suessfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  final _websiteController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Face",
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreenAccent,
          title: Text(
            "Student Attdence App",
            style: TextStyle(
              fontWeight: FontWeight.bold,
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
                  decoration: InputDecoration(hintText: "website"),
                ),

                ElevatedButton(
                  onPressed: () {
                    uploadData();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => QRcodeGenerater(
                                name: _nameController.text,
                                email: _emailController.text,
                                website: _websiteController.text,
                              )),
                    );
                  },
                  child: Text("Generate QR Code"),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QRViewExample()),
                    );
                  },
                  child: Text("Scan QR Code"),
                ),

                ElevatedButton(
                    onPressed: () {
                      uploadData();
                    },
                    child: Text("Demo")),

                ElevatedButton(
                  onPressed: () {
                    uploadData();
                    // Generate barcode instead of QR code
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BarcodeGenerator(
                          name: _nameController.text,
                          email: _emailController.text,
                          website: _websiteController.text,
                        ),
                      ),
                    );
                  },
                  child: Text("Generate Barcode"),
                ),

                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => BarcodeScanner()),
                //     );
                //   },
                //   child: Text("Scan Barcode"),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
