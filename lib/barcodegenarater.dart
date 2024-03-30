// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, use_build_context_synchronously

import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class BarcodeGenerator extends StatelessWidget {
  BarcodeGenerator({
    super.key,
    required this.name,
    required this.email,
    required this.website,
  });

  final String name;
  final String email;
  final String website;

  final ScreenshotController screenshotController = ScreenshotController();

  String generateBarcodeData() {
    return "$name\n$email\n$website";
  }

  Future<void> captureAndSaveImage(BuildContext context) async {
    final Uint8List? uint8list = await screenshotController.capture();

    if (uint8list != null) {
      final PermissionStatus status = await Permission.storage.request();
      if (status.isGranted) {
        try {
          // Generate a unique filename
          String imageName = generateUniqueFileName('barcode_screenshot.jpg');

          // Upload the image to Firebase Cloud Storage
          await uploadScreenshot(uint8list, imageName);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image uploaded to Firebase Storage'),
              duration: Duration(seconds: 2),
            ),
          );
        } catch (e) {
          // Show error message if failed to upload image
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload image: $e'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        //saved images to gallery
        final result = await ImageGallerySaver.saveImage(uint8list);
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image Saved to Gallery'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save image: ${result['error']}'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Show error message if permission denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission to access storage denied'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> uploadScreenshot(Uint8List imageBytes, String imageName) async {
    try {
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref().child(imageName);
      await ref.putData(imageBytes);
      print('Image uploaded to Firebase Storage.');
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      rethrow; // Rethrow the error to handle it in the calling function
    }
  }

  // Function to generate a unique filename
  String generateUniqueFileName(String fileName) {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '${timestamp}_$fileName';
  }

  @override
  Widget build(BuildContext context) {
    String barcodeData = generateBarcodeData();
    print(barcodeData);
    return Scaffold(
      appBar: AppBar(
        title: Text("Barcode Generator"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                )),
            SizedBox(height: 20.0),
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
