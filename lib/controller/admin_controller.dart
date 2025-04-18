import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AdminController extends GetxController {
  bool isAdmin = false;

  checkAdmin() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    if (currentUserId == 'VssRLofLypfwZjHDjyajBZYlrX03' ||
        currentUserId == 'lyFOSkkORuVcLz0ATFMRDI8NEl03') {
      isAdmin = true;
      update();
    } else {
      isAdmin = false;
      update();
    }
  }

  bool isThisUserAdmin(String userId) {
    log('checking user id $userId if this is admin');
    if (userId == 'VssRLofLypfwZjHDjyajBZYlrX03' ||
        userId == 'lyFOSkkORuVcLz0ATFMRDI8NEl03') {
      return true;
    } else {
      return false;
    }
  }

  bool isThisUserCeo(String userId) {
    log('checking user id $userId if this is admin');
    if (userId == 'VssRLofLypfwZjHDjyajBZYlrX03') {
      return true;
    } else {
      return false;
    }
  }

  @override
  void onInit() {
    checkAdmin();
    super.onInit();
  }
}
