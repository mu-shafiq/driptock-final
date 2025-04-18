import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FileUploading {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(String filePath) async {
    File file = File(filePath);

    try {
      TaskSnapshot snapshot = await _storage
          .ref('styles/${DateTime.now().millisecondsSinceEpoch}.jpg')
          .putFile(file);

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
}
