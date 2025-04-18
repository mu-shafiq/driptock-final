import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyActivitiesController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var userActivities = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserActivity();
  }

  void fetchUserActivity() {
    try {
      isLoading(true);
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        Future.delayed(Duration.zero, () {});
        return;
      }

      String actionOwnerId = currentUser.uid;

      print('Fetching activities for actionOwnerId: $actionOwnerId');

      _firestore
          .collection('activities')
          .where('actionOwnerId', isEqualTo: actionOwnerId)
          .snapshots()
          .listen((querySnapshot) {
        print('Number of documents fetched: ${querySnapshot.docs.length}');

        userActivities.value = querySnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });
    } catch (e) {
      Future.delayed(Duration.zero, () {
        Get.snackbar('Error', 'Failed to fetch activities: $e',
            snackPosition: SnackPosition.BOTTOM);
      });
    } finally {
      isLoading(false);
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Invalid date';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMMM dd, yyyy h:mm a').format(dateTime);
  }

  Future<void> deleteActivity(String actionId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('activities')
          .where('actionId', isEqualTo: actionId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print('Activity deleted successfully');
    } catch (e) {
      print('Error deleting activity: $e');
    }
  }
}
