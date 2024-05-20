// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class BarcodeGenerator extends StatefulWidget {
  final String name;
  final String email;
  final String Address;
  final String Mobile;
  final String regNo;

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

class _BarcodeGeneratorState extends State<BarcodeGenerator> {
  final ScreenshotController screenshotController = ScreenshotController();

  String generateBarcodeData() {
    return widget.regNo;
  }

  Future<void> captureAndSaveImage(BuildContext context) async {
    final Uint8List? uint8list = await screenshotController.capture();

    if (uint8list != null) {
      final PermissionStatus status = await Permission.storage.request();
      if (status.isGranted) {
        try {
          String imageName = generateUniqueFileName(widget.name);
          await uploadScreenshot(uint8list, imageName);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image uploaded to Firebase Storage'),
              duration: Duration(seconds: 2),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload image: $e'),
              duration: Duration(seconds: 2),
            ),
          );
        }
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
      rethrow;
    }
  }

  String generateUniqueFileName(String name) {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String truncatedTimestamp = timestamp.substring(0, 10);
    return '$name $truncatedTimestamp.jpg';
  }

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
