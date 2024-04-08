import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethod {
  Future addUserDetails(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc()
        .set(userInfoMap);
  }
}

// final FirebaseFirestore firestore = FirebaseFirestore.instance;
// final FirebaseStorage storage = FirebaseStorage.instance;

// // Function to upload file to Firebase Storage and store its reference in Firestore
// Future<void> uploadFileAndStoreReference() async {
//   File file = File('sdsd');
//   Reference ref = storage.ref().child('path_in_storage').child('filename');
//   UploadTask uploadTask = ref.putFile(file);
//   TaskSnapshot storageTaskSnapshot = await uploadTask;
//   String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

//   await firestore.collection('files').add({
//     'name': 'File Name',
//     'url': downloadUrl, // Store download URL in Firestore
//   });
// }

// // Function to retrieve file reference from Firestore and download it from Firebase Storage
// Future<void> downloadFile() async {
//   QuerySnapshot querySnapshot = await firestore.collection('files').get();
//   querySnapshot.docs.forEach((doc) async {
//     String downloadUrl = doc['url'];
//     Reference ref = storage.refFromURL(downloadUrl);
//     String filePath = 'local_file_path';
//     File file = File(filePath);
//     await ref.writeToFile(file);
//   });
// }

 