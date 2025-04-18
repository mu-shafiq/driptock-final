import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drip_tok/controller/user_controller.dart';
import 'package:drip_tok/screens/edit_profile_setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../model/user_profile.dart';

class UserProfileController extends GetxController {
  var profileModel = UserProfile().obs;
  var profileModelEdit = UserProfile();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    fetchUserProfile();
    print('..............${profileModel.value}');
    super.onInit();
  }

  Future<void> fetchUserProfile() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        DocumentSnapshot profileDoc = await FirebaseFirestore.instance
            .collection('user_profile')
            .doc(userId)
            .get();

        if (profileDoc.exists) {
          profileModel.value =
              UserProfile.fromMap(profileDoc.data() as Map<String, dynamic>);
          profileModelEdit = profileModel.value;
          print('User Profile fetched: ${profileModel.value}');
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

  saveVideo(String videoId) async {
    List<String> list = profileModel.value.savedDrips ?? [];

    list.contains(videoId) ? list!.remove(videoId) : list!.add(videoId);
    profileModel.value.savedDrips = List.from(list);
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('user_profile')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    DocumentSnapshot userSnapshot = await userRef.get();
    List savedDrips = userSnapshot['savedDrips'] ?? [];
    print(savedDrips);

    if (savedDrips.contains(videoId)) {
      await userRef.update({
        'savedDrips': FieldValue.arrayRemove([videoId])
      });
    } else {
      await userRef.update({
        'savedDrips': FieldValue.arrayUnion([videoId])
      });
    }
  }

  Future<void> follow(String userId) async {
    try {
      List<String> list = profileModel.value.followings ?? [];

      if (list.contains(userId)) {
        list.remove(userId);
      } else {
        list.add(userId);
      }

      profileModel.update((val) {
        val?.followings = List.from(list);
      });

      update();
      Get.find<UserController>().addFollower(userId);

      DocumentReference userRef = FirebaseFirestore.instance
          .collection('user_profile')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      DocumentSnapshot userSnapshot = await userRef.get();
      List likes = userSnapshot['followings'] ?? [];

      if (likes.contains(userId)) {
        await userRef.update({
          'followings': FieldValue.arrayRemove([userId])
        });
      } else {
        await userRef.update({
          'followings': FieldValue.arrayUnion([userId])
        });
      }

      DocumentReference userRef2 =
          FirebaseFirestore.instance.collection('user_profile').doc(userId);

      DocumentSnapshot userSnapshot2 = await userRef2.get();
      List followers = userSnapshot2['followers'] ?? [];

      if (followers.contains(FirebaseAuth.instance.currentUser!.uid)) {
        await userRef2.update({
          'followers':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      } else {
        await userRef2.update({
          'followers':
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
      }

      // **Profile screen ke liye fresh data fetch karein**
      await fetchUserProfile();

      update(); // UI ko refresh karein
    } catch (e) {
      print("Error following user: $e");
      rethrow;
    }
  }

  String formatLikesCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else {
      return count.toString();
    }
  }

  void resetProfile() {
    profileModel.value = UserProfile();
    update();
  }
}
