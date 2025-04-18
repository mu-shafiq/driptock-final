import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drip_tok/model/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  // Observable list to hold fetched users
  RxList<UserProfile> users = <UserProfile>[].obs;
  RxList<UserProfile> followList = <UserProfile>[].obs;

  // Reference to Firestore collection
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  addFollower(String uid) {
    String currUId = FirebaseAuth.instance.currentUser!.uid;
    int index = users.indexWhere((test) => test.userId == uid);
    List<String> list = users[index].followers ?? [];
    list.contains(currUId) ? list.remove(currUId) : list.add(currUId);
    users[index].followers = List.from(list);
    update();
  }

  // Fetch all users from 'user_profile' collection
  Future<void> fetchUsers() async {
    try {
      // Fetch documents from Firestore collection
      QuerySnapshot querySnapshot =
          await _firestore.collection('user_profile').get();

      // Map each document to a ProfileModel and add to the users list
      users.value = querySnapshot.docs.map((doc) {
        return UserProfile.fromMap(
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      print("Users fetched successfully!");
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  void getfollowList(List<String> userIds) async {
    followList.clear();
    // update();
    for (var id in userIds) {
      UserProfile? user = await fetchUserById(id);

      user != null ? followList.add(user) : null;
      update();
    }
  }

  Future<UserProfile?> fetchUserById(String userId) async {
    UserProfile? user;
    try {
      // Fetch documents from Firestore collection
      DocumentSnapshot docSnapshot =
          await _firestore.collection('user_profile').doc(userId).get();

      // Map each document to a ProfileModel and add to the users list
      user = UserProfile.fromMap(docSnapshot.data() as Map<String, dynamic>);

      print("Users fetched successfully!");
      return user;
    } catch (e) {
      print("Error fetching user by id: $e");
      return null;
    }
  }
}
