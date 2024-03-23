import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethod{
  Future addUserDetails(Map<String,dynamic> userInfoMap) async{
    return await FirebaseFirestore.instance
      .collection("Users")
      .doc()
      .set(userInfoMap);
  }

  Future<void> addQRCodeImage(Uint8List qrCodeImage) async {
    String base64Image = base64Encode(qrCodeImage);
    Map<String, dynamic> qrCodeMap = {
      'qrCodeImage': base64Image,
      // you can add additional metadata if needed
    };
    return await FirebaseFirestore.instance
        .collection("QRCodeImages")
        .doc()
        .set(qrCodeMap);
  }
  
}

