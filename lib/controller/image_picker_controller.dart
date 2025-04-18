import 'dart:io';
import 'package:drip_tok/services/file_uploading_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController extends GetxController {
  Rx<File?> pickedImage = Rx<File?>(null);

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      pickedImage.value = File(pickedFile.path);
    }
  }

  Future<void> createProfile() async {
    if (pickedImage.value != null) {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();

        Reference ref =
            FirebaseStorage.instance.ref().child('profile_images/$fileName');

        await ref.putFile(pickedImage.value!);

        String downloadUrl = await ref.getDownloadURL();
        // String downloadUrl =
        //     await FileUploadingService().uploadImage(pickedImage.value!) ?? '';
        await FirebaseFirestore.instance
            .collection('user_data')
            .doc('userId')
            .update({
          'profileImage': downloadUrl,
        });

        print('Image uploaded and URL stored in Firestore: $downloadUrl');
      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print('No image selected');
    }
  }

  void clear() {
    pickedImage.value = null;
    print('Profile image cleared');
  }
}
