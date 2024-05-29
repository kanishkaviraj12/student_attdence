// Import necessary packages and libraries
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names, avoid_print, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'dart:typed_data'; // For handling byte data
import 'package:firebase_storage/firebase_storage.dart'
    as firebase_storage; // For interacting with Firebase Storage
import 'package:flutter/material.dart'; // Flutter framework
import 'package:screenshot/screenshot.dart'; // For capturing screenshots
import 'package:permission_handler/permission_handler.dart'; // For handling permissions
import 'package:image_gallery_saver/image_gallery_saver.dart'; // For saving images to the device's gallery
import 'package:syncfusion_flutter_barcodes/barcodes.dart'; // For generating barcodes

// Define a StatefulWidget for generating a barcode
class BarcodeGenerator extends StatefulWidget {
  // Define properties required for generating the barcode
  final String name;
  final String email;
  final String Address;
  final String Mobile;
  final String regNo;

  // Constructor to initialize the properties
  BarcodeGenerator({
    required this.name,
    required this.email,
    required this.Address,
    required this.Mobile,
    required this.regNo,
  });

  @override
  _BarcodeGeneratorState createState() => _BarcodeGeneratorState();
}

// Define the State class for the BarcodeGenerator widget
class _BarcodeGeneratorState extends State<BarcodeGenerator> {
  // Create a controller for capturing screenshots
  final ScreenshotController screenshotController = ScreenshotController();

  // Method to generate data for the barcode
  String generateBarcodeData() {
    return widget.regNo;
  }

  // Method to capture and save the barcode as an image
  Future<void> captureAndSaveImage(BuildContext context) async {
    // Capture the screenshot
    final Uint8List? uint8list = await screenshotController.capture();

    // Check if the screenshot is captured successfully
    if (uint8list != null) {
      // Request permission to access storage
      final PermissionStatus status = await Permission.storage.request();

      // Check if permission is granted
      if (status.isGranted) {
        try {
          // Generate a unique filename for the image
          String imageName = generateUniqueFileName(widget.name);

          // Upload the screenshot to Firebase Storage
          await uploadScreenshot(uint8list, imageName);

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image uploaded to Firebase Storage'),
              duration: Duration(seconds: 2),
            ),
          );
        } catch (e) {
          // Show an error message if uploading fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload image: $e'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Save the image to the device's gallery
        final result = await ImageGallerySaver.saveImage(uint8list);
        if (result['isSuccess']) {
          // Show a success message if saving succeeds
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image Saved to Gallery'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Show an error message if saving fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save image: ${result['error']}'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Show a message if permission to access storage is denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission to access storage denied'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Method to upload the screenshot to Firebase Storage
  // are parameters of the uploadScreenshot function.
  Future<void> uploadScreenshot(Uint8List imageBytes, String imageName) async {
    try {
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref().child(imageName);
      await ref.putData(imageBytes);
      print('Image uploaded to Firebase Storage.');
    } catch (e) {
      // Print error message if uploading fails
      print('Error uploading image to Firebase Storage: $e');
      rethrow;
    }
  }

  // Method to generate a unique filename for the image
  String generateUniqueFileName(String name) {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String truncatedTimestamp = timestamp.substring(0, 10);
    return '$name $truncatedTimestamp.jpg';
  }

  // Build method to construct the widget
  @override
  Widget build(BuildContext context) {
    String barcodeData = generateBarcodeData();
    return Scaffold(
      appBar: AppBar(
        title: Text("Barcode Generator"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Widget to display the barcode
            Screenshot(
              controller: screenshotController,
              child: SizedBox(
                height: 200,
                width: 400,
                child: SfBarcodeGenerator(
                  value: barcodeData,
                  symbology: Code128(),
                  showValue: false,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            // Button to capture and save the barcode as an image
            Text("Scan Barcode"),
            ElevatedButton(
              onPressed: () async {
                await captureAndSaveImage(context);
              },
              child: Text("Capture and save as image"),
            )
          ],
        ),
      ),
    );
  }
}
