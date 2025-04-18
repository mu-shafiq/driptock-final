import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StyleTransferController extends GetxController {
  List<Map<String, dynamic>> files = [];
  bool loading = false;
  bool isFetched = false;
  Rx<int> downloadCount = 0.obs;
  Rx<int> sharingCount = 0.obs;

  Future<void> fetchStylesFromFirestore() async {
    try {
      loading = true;
      update();

      if (isFetched) return;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('styles')
          .orderBy('downloadCount', descending: true)
          .orderBy('sharingCount', descending: true)
          .limit(100)
          .get();

      List<Future> downloadFutures = [];

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        String imageUrl = doc['imageUrl'] as String;
        String styleId = doc.id;

        // await storeStyleId(styleId);

        if (Uri.parse(imageUrl).isAbsolute) {
          // Add the image download task to the list of futures
          downloadFutures.add(_downloadImage(imageUrl, styleId));
        } else {
          var file = File(imageUrl);
          files.add({"file": file, "id": styleId});
          update();
        }
      }

      // Wait for all image download tasks to complete
      await Future.wait(downloadFutures);

      isFetched = true;
      loading = false;
      update();
    } catch (e) {
      loading = false;
      log('Error fetching styles from Firestore: $e');
      update();
    }
  }

  Future<void> _downloadImage(String imageUrl, String styleId) async {
    try {
      var response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        var bytes = response.bodyBytes;
        var file = await _saveImageToFile(bytes);
        files.add({"file": file, "id": styleId});
        loading = false;
        update();
      } else {
        await deleteStyleWithId(styleId);
        log('Failed to download image: $imageUrl');
      }
    } catch (e) {
      log('Error downloading image: $e');
    }
  }

  Future<File> _saveImageToFile(Uint8List bytes) async {
    String tempPath = (await getTemporaryDirectory()).path;
    String filePath = '$tempPath/${DateTime.now().millisecondsSinceEpoch}.png';
    return File(filePath).writeAsBytes(bytes);
  }

  void clearStyles() {
    isFetched = false;
    files.clear();
    update();
  }

  Future<void> uploadToFirestore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      String activityId =
          FirebaseFirestore.instance.collection('activities').doc().id;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('activities').add({
          'actionId': activityId,
          'actiontitle': 'Style',
          'actionbody':
              'We analyzed your photo and found style that perfectly suit your look-explore now',
          'actionOwnerId': userId,
          'timestamp': Timestamp.now(),
        });
        print('Document uploaded successfully');
      } else {
        print('No user is logged in');
      }
    } catch (e) {
      print('Error uploading document: $e');
    }
  }

  deleteStyleWithId(String styleId) async {
    files.removeWhere((style) => style['id'] == styleId);
    update();
    await FirebaseFirestore.instance.collection('styles').doc(styleId).delete();
  }
}
