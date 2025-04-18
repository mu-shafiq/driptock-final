import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:drip_tok/model/user_model.dart';
import 'package:drip_tok/model/user_profile.dart';
import 'package:drip_tok/services/file_uploading_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../controller/user_profile_Controller.dart';

class FirestoreServices {
  //Upload signup data
  static Future<void> uploadUserData(
      {required UserModel usermodel, required String docId}) async {
    FirebaseFirestore.instance
        .collection('user_data')
        .doc(docId)
        .set(usermodel.toMap());
  }

  //Upload profile data
  static Future<void> uploadProfileData(
      {required UserProfile userprofile, required String docId}) async {
    FirebaseFirestore.instance
        .collection('user_profile')
        .doc(docId)
        .set(userprofile.toMap());
    await Get.delete<UserProfileController>();
    Get.put(UserProfileController());
    Get.find<UserProfileController>().fetchUserProfile();
  }

  // upload profile image
  static Future<String?> uploadProfileImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${const Uuid().v4()}');

      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});

      final downloadUrl = await snapshot.ref.getDownloadURL();
      //   final downloadUrl = await FileUploadingService().uploadImage(image);

      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
