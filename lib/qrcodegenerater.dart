// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, use_build_context_synchronously

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class QRcodeGenerater extends StatelessWidget {
  QRcodeGenerater({
    super.key,
    required this.name,
    required this.email,
    required this.website,
    required this.regNo,
  });

  final String name;
  final String email;
  final String website;
  final String regNo;

  final ScreenshotController screenshotController = ScreenshotController();

  String generateQRData() {
    return "Name: $name\n Email: $email\n Website: $website \n Reg No: $regNo";
  }

  Future<void> CaptureAndSaveImage(BuildContext context) async {
    final Uint8List? uint8list = await screenshotController.capture();

    if (uint8list != null) {
      final PermissionStatus status = await Permission.storage.request();
      if (status.isGranted) {
        final result = await ImageGallerySaver.saveImage(uint8list);
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image Saved to Gallery'),
              duration: Duration(seconds: 2), // Adjust duration as needed
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save image: ${result['error']}'),
              duration: Duration(seconds: 2), // Adjust duration as needed
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission to access storage denied'),
            duration: Duration(seconds: 2), // Adjust duration as needed
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String qrData = generateQRData();
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Generater"),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Screenshot(
            controller: screenshotController,
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              gapless: false,
              size: 220,
              backgroundColor: Colors.white,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Text("Scan QR Code"),
          ElevatedButton(
            onPressed: () async {
              await CaptureAndSaveImage(context);
            },
            child: Text("Capture and save as image"),
          )
        ],
      )),
    );
  }
}
