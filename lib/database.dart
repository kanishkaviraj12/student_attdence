import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethod {
  Future addUserDetails(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc()
        .set(userInfoMap);
  }
}
