import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../model/user_model.dart';

class UserDataController extends GetxController {
  var userModel = UserModel().obs;

  @override
  void onInit() {
    fetchUserData();
    print('..............${userModel.value}');
    super.onInit();
  }

  Future<void> fetchUserData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      print('................................jdjbdjkw$userId');
      try {
        DocumentSnapshot profileDoc = await FirebaseFirestore.instance
            .collection('user_data')
            .doc(userId)
            .get();

        if (profileDoc.exists) {
          userModel.value =
              UserModel.fromMap(profileDoc.data() as Map<String, dynamic>);
          print('User Profile fetched: ${userModel.value}');
        } else {
          print('User profile does not exist.');
        }

        update();
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    } else {
      print('User not logged in');
    }
  }
}
