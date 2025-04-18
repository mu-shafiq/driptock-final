import 'dart:developer';
import 'package:drip_tok/model/video_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';

import '../model/comment_model.dart';
import '../model/user_profile.dart';
import 'user_profile_Controller.dart';

class MyDripsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool loading = false;
  // int videoControllerIndex = 0;
  final RxList<VideoModel> savedDrips = <VideoModel>[].obs;
  final RxList<VideoModel> userVideos = <VideoModel>[].obs;
  // final RxList<VideoModel> videoList = <VideoModel>[].obs;

  var isLoading = true.obs;
  RxInt cmntCount = 0.obs;
  bool commentsLoading = true;
  VideoPlayerController? videoPlayerController;
  @override
  void onInit() {
    super.onInit();

    // fetchUserVideos();

    // fetchSavedDrips(FirebaseAuth.instance.currentUser!.uid);
  }

  // setVideoControllerIndex(int val) {
  //   videoControllerIndex = val;
  // }

  Future<void> fetchSavedDrips(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('reels')
          .where('savedBy', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();

      log('fetching....');
      savedDrips.clear();
      print(querySnapshot.docs.length);

      for (var doc in querySnapshot.docs) {
        VideoModel video =
            VideoModel.fromMap(doc.data() as Map<String, dynamic>);

        savedDrips.add(video);
      }
    } catch (e) {
      print("Error fetching saved drips: $e");
    }
  }

  Future<VideoPlayerController?> intializeVideoController(
      String videoLink, String videoId) async {
    update();

    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(videoLink))
          ..initialize().then((_) {
            log('Video player initialized successfully');
            log('................${userVideos.length}');
            update();
          }).catchError((error) {
            update();
          })
          ..play()
          ..addListener(() {
            update();
          });

    fetchCommentCount(videoId);
    // ..setLooping(true)
    // if (FirebaseAuth.instance.currentUser != null) {
    //   videoControllerList[0].play();
    // }
    // ..play();
    update();
  }

  // Future<VideoPlayerController?> intializedallDripsVideoController() async {
  //   for (var v = 1; v < userVideos.length; v++) {
  //     videoControllerList[v] =
  //         VideoPlayerController.networkUrl(Uri.parse(userVideos[v].videoUrl))
  //           ..initialize().then((_) {
  //             log('Video player initialized successfully');
  //           }).catchError((error) {
  //             update();
  //           })
  //           ..addListener(() {
  //             update();
  //           })
  //           ..setLooping(true)
  //           ..pause();
  //   }
  //   return null;
  // }

  // Future<void> fetchAllVideos() async {
  //   try {
  //     loading = true;
  //     update();
  //     final User? currentUser = _auth.currentUser;

  //     if (currentUser == null) {
  //       throw Exception("User is not logged in");
  //     }

  //     String userId = currentUser.uid;

  //     QuerySnapshot snapshot = await _firestore
  //         .collection('reels')
  //         .where('userId', isEqualTo: userId)
  //         // .orderBy('createdAt', descending: true)
  //         .get();

  //     for (var doc in snapshot.docs) {
  //       VideoModel video =
  //           VideoModel.fromMap(doc.data() as Map<String, dynamic>);
  //       final fileName = await VideoThumbnail.thumbnailFile(
  //         video: video.videoUrl,
  //         thumbnailPath: (await getTemporaryDirectory()).path,
  //       );
  //     }

  //     loading = false;
  //     update();
  //     videoControllerList = List.generate(
  //         userVideos.length,
  //         (int index) => VideoPlayerController.networkUrl(
  //             Uri.parse(userVideos[index].videoUrl)));

  //     print('...............The length of videos${userVideos.length}');
  //   } catch (e) {
  //     loading = false;
  //     update();
  //     print("Error fetching videos: $e");
  //     rethrow;
  //   }
  // }

  void deleteDrip(String dripId) async {
    await _firestore.collection('reels').doc(dripId).delete();
  }

  void fetchUserVideos(String userId) async {
    try {
      isLoading(true);

      QuerySnapshot querySnapshot = await _firestore
          .collection('reels')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      log('fetching....');
      userVideos.clear();
      print(querySnapshot.docs.length);

      for (var doc in querySnapshot.docs) {
        VideoModel video =
            VideoModel.fromMap(doc.data() as Map<String, dynamic>);

        userVideos.add(video);
      }

      update();

      // await intializeVideoController(userVideos.first.videoUrl);
      // intializedallDripsVideoController();
    } catch (e) {
      log(e.toString());
      //    Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // initializeOnTabChange(List<VideoModel> videos) async {
  //   setVideoControllerIndex(0);
  //   videoControllerList = List.generate(
  //       videos.length,
  //       (int index) => VideoPlayerController.networkUrl(
  //           Uri.parse(videos[index].videoUrl)));
  //   await intializeVideoController(videos.first.videoUrl);

  //   for (var v = 1; v < videos.length; v++) {
  //     videoControllerList[v] =
  //         VideoPlayerController.networkUrl(Uri.parse(videos[v].videoUrl))
  //           ..initialize().then((_) {
  //             log('Video player initialized successfully');
  //           }).catchError((error) {
  //             update();
  //           })
  //           ..addListener(() {
  //             update();
  //           })
  //           ..setLooping(true)
  //           ..pause();
  //   }
  // }

  Future<void> likeVideo(String videoId, String userId) async {
    try {
      int index = userVideos.indexWhere((video) => video.videoId == videoId);
      if (index != -1) {
        var updatedVideo = userVideos[index];
        userVideos[index].likes.contains(userId)
            ? updatedVideo.likes.remove(userId)
            : updatedVideo.likes.add(userId);
        userVideos[index] = updatedVideo;
      } else {
        int index = savedDrips.indexWhere((video) => video.videoId == videoId);
        var updatedVideo = savedDrips[index];
        savedDrips[index].likes.contains(userId)
            ? updatedVideo.likes.remove(userId)
            : updatedVideo.likes.add(userId);
        savedDrips[index] = updatedVideo;
      }
      update();
      DocumentReference videoRef = _firestore.collection('reels').doc(videoId);
      DocumentSnapshot videoSnapshot = await videoRef.get();

      String videoOwnerId = videoSnapshot['userId'];
      print("Video Owner's UserID: $videoOwnerId");

      List likes = videoSnapshot['likes'];

      if (likes.contains(userId)) {
        await videoRef.update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await videoRef.update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }

      DocumentSnapshot userSnapshot =
          await _firestore.collection('user_profile').doc(userId).get();
      String username = userSnapshot['username'] ?? 'Unknown User';
      print("Username: $username");

      DocumentSnapshot videoOwnerSnapshot =
          await _firestore.collection('user_profile').doc(videoOwnerId).get();
      String videoOwnerUsername =
          videoOwnerSnapshot['username'] ?? 'Unknown Video Owner';
      print("Video Owner's Username: $videoOwnerUsername");

      await _firestore.collection('activities').add({
        'userId': userId,
        'actionId': videoId,
        'actiontitle': 'Like',
        'actionbody': '$username has liked your video',
        'timestamp': Timestamp.now(),
        'actionOwnerId': videoOwnerId,
      });
    } catch (e) {
      print("Error liking video: $e");
      rethrow;
    }
  }

  Future<void> saveVideo(String videoId, String userId) async {
    try {
      bool isSaved = false;

      int index = userVideos.indexWhere((video) => video.videoId == videoId);
      if (index != -1) {
        var updatedVideo = userVideos[index];
        if (updatedVideo.savedBy!.contains(userId)) {
          updatedVideo.savedBy?.remove(userId);
          savedDrips.removeWhere((video) => video.videoId == videoId);
        } else {
          updatedVideo.savedBy?.add(userId);
          isSaved = true;
        }
        userVideos[index] = updatedVideo;
      } else {
        int index = savedDrips.indexWhere((video) => video.videoId == videoId);
        if (index != -1) {
          var updatedVideo = savedDrips[index];
          if (updatedVideo.savedBy!.contains(userId)) {
            updatedVideo.savedBy?.remove(userId);
            savedDrips.removeAt(index);
          } else {
            updatedVideo.savedBy?.add(userId);
            isSaved = true;
          }
          savedDrips[index] = updatedVideo;
        }
      }

      update();

      DocumentReference videoRef = _firestore.collection('reels').doc(videoId);
      DocumentSnapshot videoSnapshot = await videoRef.get();
      List saves = videoSnapshot['savedBy'] ?? [];

      if (saves.contains(userId)) {
        await videoRef.update({
          'savedBy': FieldValue.arrayRemove([userId])
        });
      } else {
        await videoRef.update({
          'savedBy': FieldValue.arrayUnion([userId])
        });
      }

      if (isSaved) {
        await fetchSavedDrips(userId);
      }

      update();
    } catch (e) {
      print("Error saving video: $e");
      rethrow;
    }
  }

  Future<void> addComment(String videoId, String userId, String comment) async {
    try {
      CommentModel newComment = CommentModel(
        commentId: _firestore.collection('comments').doc().id,
        userId: userId,
        comment: comment,
        likes: [],
        createdAt: DateTime.now(),
      );

      // Convert the comment to a map
      Map<String, dynamic> commentMap = newComment.toMap();

      // Use arrayUnion to add the comment to the comments list
      await _firestore.collection('comments').doc(videoId).set({
        'comments': FieldValue.arrayUnion([commentMap])
      }, SetOptions(merge: true));

      // Update the local video list
      int index = userVideos.indexWhere((video) => video.videoId == videoId);
      if (index != -1) {
        newComment.user = Get.find<UserProfileController>().profileModel.value;
        userVideos[index].comments.add(newComment);
      }
    } catch (e) {
      print("Error adding comment: $e");
      rethrow;
    }
  }

  clearComments(String videoId) {
    int index = userVideos.indexWhere((video) => video.videoId == videoId);
    if (index != -1) {
      userVideos[index].comments = [];
    }
    commentsLoading = true;
  }

  Future<void> fetchVideoComment(String videoId) async {
    try {
      commentsLoading = true;
      update();
      // Fetch the document for the given video ID
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('comments').doc(videoId).get();

      // Check if the document exists and has comments
      if (docSnapshot.exists && docSnapshot.data() != null) {
        List<dynamic> commentsData = docSnapshot.data()?['comments'] ?? [];
        List<CommentModel> comments = [];

        // Parse the comments data into a list of CommentModel
        for (var comment in commentsData) {
          CommentModel commentModel = CommentModel.fromMap(comment);
          final userDoc = await FirebaseFirestore.instance
              .collection('user_profile')
              .doc(commentModel.userId)
              .get();

          UserProfile? user;
          if (userDoc.exists) {
            user = UserProfile.fromMap(userDoc.data()!);
            commentModel.user = user;
            comments.add(commentModel);
          }
        }

        // Update the local video list
        int index = userVideos.indexWhere((video) => video.videoId == videoId);
        if (index != -1) {
          userVideos[index].comments = comments;
        }
      }
      commentsLoading = false;
      update();
    } catch (e) {
      commentsLoading = false;
      update();
      print("Error fetching comments: $e");
      rethrow;
    }
  }

  fetchCommentCount(String videoId) async {
    cmntCount.value = 0;
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('comments').doc(videoId).get();

      // Check if the document exists and has comments
      if (docSnapshot.exists && docSnapshot.data() != null) {
        List<dynamic> commentsData = docSnapshot.data()?['comments'] ?? [];
        cmntCount.value = commentsData.length;
      }
    } catch (e) {
      print('failed to fetch cmn count');
    }
  }

  /// Reply to a comment
  Future<void> replyToComment(
      String videoId, String commentId, String userId, String reply) async {
    try {
      String replyId = _firestore
          .collection('reels')
          .doc(videoId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc()
          .id;

      await _firestore
          .collection('reels')
          .doc(videoId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .set({
        'replyId': replyId,
        'userId': userId,
        'reply': reply,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error replying to comment: $e");
      rethrow;
    }
  }

  /// Like a comment
  Future<void> likeComment(
      String videoId, String commentId, String userId) async {
    try {
      DocumentSnapshot videoSnapshot =
          await _firestore.collection('reels').doc(videoId).get();
      String videoOwnerId = videoSnapshot['userId'];
      print("Video Owner's UserID: $videoOwnerId");

      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('comments').doc(videoId).get();

      List<dynamic> comments = [];
      if (docSnapshot.exists && docSnapshot.data() != null) {
        comments = docSnapshot.data()?['comments'] ?? [];
      }

      for (var comment in comments) {
        if (comment['commentId'] == commentId) {
          List likes = comment['likes'] ?? [];
          if (likes.contains(userId)) {
            likes.remove(userId);
          } else {
            likes.add(userId);
          }
          comment['likes'] = likes;
          break;
        }
      }

      await _firestore
          .collection('comments')
          .doc(videoId)
          .set({'comments': comments}, SetOptions(merge: true));

      DocumentSnapshot userSnapshot =
          await _firestore.collection('user_profile').doc(userId).get();
      String username = userSnapshot['username'] ?? 'Unknown User';
      print("Username: $username");

      DocumentSnapshot videoOwnerSnapshot =
          await _firestore.collection('user_profile').doc(videoOwnerId).get();
      String videoOwnerUsername =
          videoOwnerSnapshot['username'] ?? 'Unknown Video Owner';
      print("Video Owner's Username: $videoOwnerUsername");

      await _firestore.collection('activities').add({
        'userId': userId,
        'actionId': commentId,
        'actiontitle': 'Like',
        'actionbody': '$username has liked your comment',
        'timestamp': Timestamp.now(),
        'actionOwnerId': videoOwnerId,
      });

      int videoIndex =
          userVideos.indexWhere((video) => video.videoId == videoId);
      if (videoIndex != -1) {
        int commentIndex = userVideos[videoIndex]
            .comments
            .indexWhere((comment) => comment.commentId == commentId);
        if (commentIndex != -1) {
          userVideos[videoIndex].comments[commentIndex].likes =
              List<String>.from(comments[commentIndex]['likes']);
        }
      }

      update();
    } catch (e) {
      print("Error liking comment: $e");
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
}
