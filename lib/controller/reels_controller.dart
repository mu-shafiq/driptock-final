import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drip_tok/constants/bottom_navigation.dart';
import 'package:drip_tok/controller/my_drips_controllere.dart';
import 'package:drip_tok/controller/user_profile_Controller.dart';
import 'package:drip_tok/model/comment_model.dart';
import 'package:drip_tok/model/user_profile.dart';
import 'package:drip_tok/model/video_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:video_player/video_player.dart';

class ReelsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  bool uploading = false;
  bool loading = false;
  bool commentsLoading = true;
  RxInt cmntCount = 0.obs;
  int videoControllerIndex = 0;
  int controllerOptimizationLength = 5;

  bool repliesLoading = false;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Reactive variables
  final RxList<VideoModel> videoList = <VideoModel>[].obs;
  List<VideoPlayerController?> videoControllerList = <VideoPlayerController>[];

  // VideoPlayerController? videoController;

  setVideoControllerIndex(int val) {
    videoControllerIndex = val;
  }

  Future<VideoPlayerController?> intializeVideoController(
    String videoLink,
  ) async {
    update();

    videoControllerList[0] =
        VideoPlayerController.networkUrl(Uri.parse(videoLink))
          ..initialize().then((_) {
            log('Video player initialized successfully');
            update();
          }).catchError((error) {
            update();
          })
          ..addListener(() {
            update();
          });
    // ..setLooping(true)
    videoControllerList[0]!.pause();
    // ..play();
    update();

    return videoControllerList[0];
  }

  Future<VideoPlayerController?> intializeAllVideoController() async {
    for (var v = 0;
        v <
            (videoList.length > controllerOptimizationLength
                ? controllerOptimizationLength
                : videoList.length);
        v++) {
      log('initializing...${videoList[v].videoUrl}');
      videoControllerList[v] =
          VideoPlayerController.networkUrl(Uri.parse(videoList[v].videoUrl))
            ..initialize().then((_) {
              log('Video player initialized successfully');
            })
            // .catchError((error) {
            //   update();
            // })
            ..addListener(() {
              update();
            })
            ..setLooping(true)
            ..pause();
    }

    return null;
  }

  void handleControllersOnPageForward(int controllerIndex) {
    if (controllerIndex >= 2 && controllerIndex + 3 < videoList.length) {
      // Dispose of the oldest controller (two steps behind)
      int disposeIndex = controllerIndex - 2;
      if (videoControllerList[disposeIndex] != null) {
        videoControllerList[disposeIndex]?.dispose();
        videoControllerList[disposeIndex] = null;
      }

      // Initialize new controller ahead
      int newIndex = controllerIndex + 3;
      if (videoControllerList[newIndex] == null &&
          newIndex < videoList.length) {
        VideoPlayerController newController = VideoPlayerController.networkUrl(
          Uri.parse(videoList[newIndex].videoUrl),
        )
          ..initialize().then((_) => update())
          ..pause();

        videoControllerList[newIndex] = newController;
      }

      log('Forward: Disposed $disposeIndex | Initialized $newIndex');
      update();
    }
  }

  void handleControllersOnPageBackward(int controllerIndex) {
    if (controllerIndex >= 2 && controllerIndex < videoList.length) {
      // Dispose of the oldest forward controller
      int disposeIndex = controllerIndex + 3;
      if (disposeIndex < videoControllerList.length &&
          videoControllerList[disposeIndex] != null) {
        videoControllerList[disposeIndex]?.dispose();
        videoControllerList[disposeIndex] = null;
      }

      // Initialize new controller behind
      int newIndex = controllerIndex - 2;
      if (newIndex >= 0 && videoControllerList[newIndex] == null) {
        VideoPlayerController newController = VideoPlayerController.networkUrl(
          Uri.parse(videoList[newIndex].videoUrl),
        )
          ..initialize().then((_) => update())
          ..pause();

        videoControllerList[newIndex] = newController;
      }

      log('Backward: Disposed $disposeIndex | Initialized $newIndex');
      update();
    }
  }

  /// Upload a video
  Future<void> uploadVideo(
    File videoFile,
    String description,
    File thumnail,
    bool isPhoto,
  ) async {
    try {
      uploading = true;
      update();
      String videoId = _firestore.collection('reels').doc().id;

      String thumnailUrl =
          await _uploadVideoThumnailToStorage(videoId, thumnail!);
      if (thumnailUrl.isEmpty || thumnailUrl == null) {
        thumnailUrl =
            'https://images.unsplash.com/photo-1581362716668-90cdec6b4882?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cGxhaW4lMjBibGFjayUyMGJhY2tncm91bmR8ZW58MHx8MHx8fDA%3D';
      }
      log('uploading...................');
      String videoUrl = await _uploadVideoToStorage(videoId, videoFile);

      VideoModel video = VideoModel(
        videoId: videoId,
        description: description,
        userId: FirebaseAuth.instance.currentUser!.uid,
        userImage: Get.find<UserProfileController>().profileModel.value.image!,
        userName:
            Get.find<UserProfileController>().profileModel.value.username!,
        videoUrl: videoUrl,
        isPhoto: isPhoto,
        thumbnail: thumnailUrl,
        likes: [],
        createdAt: Timestamp.now(),
        comments: [],
      );
      videoList.insert(0, video);

      Get.find<MyDripsController>()
          .fetchUserVideos(FirebaseAuth.instance.currentUser!.uid);
      await _firestore.collection('reels').doc(videoId).set(video.toMap());
      uploading = false;
      update();
      Get.offAll(const MainScreen());
      // Update the local video list
    } catch (e) {
      uploading = false;
      update();
      Get.back();
      print("Error uploading video: $e");
      rethrow;
    }
  }

  deleteVideo(String videoId) async {
    try {
      await _firestore.collection('reels').doc(videoId).delete();
      update();
      fetchAllVideos();
    } catch (e) {
      log('error deleting the video $e');
    }
  }

  restrictVideo(String videoId) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      List<String> blockedVideos =
          sharedPreferences.getStringList('blockedVideos') ?? [];
      blockedVideos.add(videoId);
      await sharedPreferences.setStringList('blockedVideos', blockedVideos);
      update();
      fetchAllVideos();
    } catch (e) {
      log('error deleting the video $e');
    }
  }

  // Future<File?> generateThumbnail(String videoPath) async {
  //   final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  //   final Directory tempDir = await getTemporaryDirectory();
  //   Random rnd = Random();
  //   final String outputPath =
  //       '${tempDir.path}/thumnails${rnd.nextInt(53334574)}.jpg';

  //   try {
  //     final int resultCode = await _ffmpeg.execute(
  //         // '-i $videoPath -ss 00:00:02 -vframes 1 $outputPath',
  //         'ffmpeg -ss 00:00:02 -i $videoPath -frames:v 1 -q:v 2 $outputPath');
  //     // final fileName = await VideoThumbnail.thumbnailFile(
  //     //   video: videoPath.toString(),
  //     //   thumbnailPath: outputPath,
  //     //   // imageFormat: ImageFormat.,
  //     //   quality: 100,
  //     // );
  //     log(resultCode.toString());
  //     if (resultCode == 1) {
  //       return File(outputPath);
  //     } else {
  //       log('Failed to capture ss: $outputPath');
  //       return null;
  //     }
  //   } catch (e) {
  //     log('Error generating thumbnail: $e');
  //     return null;
  //   }
  // }

  /// Fetch all videos
  Future<void> fetchAllVideos() async {
    try {
      loading = true;
      update();

      // Clear the list before fetching new videos to prevent duplicates
      videoList.clear();
      videoControllerList.clear();
      videoControllerIndex = 0;

      QuerySnapshot snapshot = await _firestore
          .collection('reels')
          .orderBy('createdAt', descending: true)
          .get();

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      List<String> blockedVideos =
          sharedPreferences.getStringList('blockedVideos') ?? [];

      print("Videos fetched: ${snapshot.docs.length} documents found.");

      for (var video in snapshot.docs) {
        VideoModel videoModel =
            VideoModel.fromMap(video.data() as Map<String, dynamic>);

        if (!blockedVideos.contains(videoModel.userId)) {
          videoList.add(videoModel);
        }
      }

      videoControllerList =
          List.generate(videoList.length, (int index) => null);

      if (videoList.isNotEmpty) {
        print("Fetching comment count for video: ${videoList.first.videoId}");
        fetchCommentCount(videoList.first.videoId);
        print("Initializing video controller for first video...");
        await intializeAllVideoController();
      } else {
        print("No videos found to play.");
      }
      loading = false;
      update();
    } catch (e) {
      loading = false;
      update();
      print("Error fetching videos: $e");
      rethrow;
    }
  }

  Future<void> likeVideo(String videoId, String userId) async {
    try {
      int index = videoList.indexWhere((video) => video.videoId == videoId);
      if (index != -1) {
        var updatedVideo = videoList[index];
        videoList[index].likes.contains(userId)
            ? updatedVideo.likes.remove(userId)
            : updatedVideo.likes.add(userId);
        videoList[index] = updatedVideo;
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
    } catch (e) {
      print("Error liking video: $e");
      rethrow;
    }
  }

  Future<void> saveVideo(String videoId, String userId) async {
    try {
      int index = videoList.indexWhere((video) => video.videoId == videoId);
      if (index != -1) {
        var updatedVideo = videoList[index];
        videoList[index].savedBy!.contains(userId)
            ? updatedVideo.savedBy?.remove(userId)
            : updatedVideo.savedBy?.add(userId);
        videoList[index] = updatedVideo;
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

      Get.find<UserProfileController>().saveVideo(videoId);
    } catch (e) {
      print("Error liking video: $e");
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

      Map<String, dynamic> commentMap = newComment.toMap();

      // Use arrayUnion to add the comment to the comments list
      await _firestore.collection('comments').doc(videoId).set({
        'comments': FieldValue.arrayUnion([commentMap])
      }, SetOptions(merge: true));

      // Update the local video list
      int index = videoList.indexWhere((video) => video.videoId == videoId);
      if (index != -1) {
        newComment.user = Get.find<UserProfileController>().profileModel.value;
        videoList[index].comments.add(newComment);
      }
      update();
      await _firestore.collection('activities').add({
        'userId': userId,
        'actionId': newComment.commentId,
        'videoId': videoId,
        'actiontitle': 'Comment',
        'actionbody':
            '${newComment.user?.username ?? 'Test'} has liked your comment',
        'timestamp': Timestamp.now(),
        'actionOwnerId': videoList[index].userId,
      });
      update();
    } catch (e) {
      print("Error adding comment: $e");
      rethrow;
    }
  }

  clearComments(String videoId) {
    int index = videoList.indexWhere((video) => video.videoId == videoId);
    if (index != -1) {
      videoList[index].comments = [];
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
        int index = videoList.indexWhere((video) => video.videoId == videoId);
        if (index != -1) {
          videoList[index].comments = comments;
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

  void fetchCommentCount(String videoId) {
    cmntCount.value = 0;
    _firestore
        .collection('comments')
        .doc(videoId)
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        List<dynamic> commentsData = docSnapshot.data()?['comments'] ?? [];
        int totalCount = commentsData.length;

        for (var comment in commentsData) {
          List<dynamic> replies = comment['replies'] ?? [];
          totalCount += replies.length;
        }

        cmntCount.value = totalCount;
      }
    });
  }

  Future<void> addReply(String videoId, String commentId, String userId,
      String reply, String replyusername) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User is not logged in');
      return;
    }

    // Fetch the user's name
    final userDoc = await FirebaseFirestore.instance
        .collection('user_profile')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      print('User data not found');
      return;
    }

    final userName = userDoc.data()?['username'] ?? 'Anonymous';

    try {
      ReplyModel newReply = ReplyModel(
        replyId: _firestore.collection('replies').doc().id,
        userId: userId,
        replyText: reply,
        replyusername: userName,
        createdAt: DateTime.now(),
      );
      Map<String, dynamic> replyMap = newReply.toMap();
      DocumentReference videoDoc =
          _firestore.collection('comments').doc(videoId);
      DocumentSnapshot videoSnapshot = await videoDoc.get();
      if (videoSnapshot.exists) {
        Map<String, dynamic> videoData =
            videoSnapshot.data() as Map<String, dynamic>;
        List<dynamic> comments = videoData['comments'] ?? [];
        int commentIndex =
            comments.indexWhere((c) => c['commentId'] == commentId);
        if (commentIndex != -1) {
          List<dynamic> replies = comments[commentIndex]['replies'] ?? [];
          replies.add(replyMap);
          comments[commentIndex]['replies'] = replies;
          await videoDoc.update({'comments': comments});
        }
      }

      int videoIndex =
          videoList.indexWhere((video) => video.videoId == videoId);
      if (videoIndex != -1) {
        int commentIndex = videoList[videoIndex]
            .comments
            .indexWhere((comment) => comment.commentId == commentId);
        if (commentIndex != -1) {
          newReply.user = Get.find<UserProfileController>().profileModel.value;
          videoList[videoIndex].comments[commentIndex].replies.add(newReply);
        }
      }
    } catch (e) {
      print("Error adding reply: $e");
      rethrow;
    }
  }

  Future<void> fetchReplies(String videoId, String commentId) async {
    try {
      repliesLoading = true;
      update();
      DocumentSnapshot<Map<String, dynamic>> videoDoc =
          await _firestore.collection('comments').doc(videoId).get();

      if (videoDoc.exists && videoDoc.data() != null) {
        Map<String, dynamic> videoData = videoDoc.data()!;
        List<dynamic> commentsData = videoData['comments'] ?? [];

        int commentIndex = commentsData
            .indexWhere((comment) => comment['commentId'] == commentId);

        if (commentIndex != -1) {
          List<dynamic> repliesData =
              commentsData[commentIndex]['replies'] ?? [];
          List<ReplyModel> replies = [];
          for (var reply in repliesData) {
            ReplyModel replyModel = ReplyModel.fromMap(reply);
            final userDoc = await _firestore
                .collection('user_profile')
                .doc(replyModel.userId)
                .get();

            UserProfile? user;
            if (userDoc.exists) {
              user = UserProfile.fromMap(userDoc.data()!);
              replyModel.user = user;
            }
            replies.add(replyModel);
          }
          int videoIndex =
              videoList.indexWhere((video) => video.videoId == videoId);

          if (videoIndex != -1) {
            int commentIndex = videoList[videoIndex]
                .comments
                .indexWhere((comment) => comment.commentId == commentId);

            if (commentIndex != -1) {
              videoList[videoIndex].comments[commentIndex].replies = replies;
            }
          }
        }
      }

      repliesLoading = false;
      update();
    } catch (e) {
      repliesLoading = false;
      update();
      print("Error fetching replies: $e");
      rethrow;
    }
  }

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
        'videoId': videoId,
        'actiontitle': 'Comment',
        'actionbody': '$username has liked your comment',
        'timestamp': Timestamp.now(),
        'actionOwnerId': videoOwnerId,
      });

      int videoIndex =
          videoList.indexWhere((video) => video.videoId == videoId);
      if (videoIndex != -1) {
        int commentIndex = videoList[videoIndex]
            .comments
            .indexWhere((comment) => comment.commentId == commentId);
        if (commentIndex != -1) {
          videoList[videoIndex].comments[commentIndex].likes =
              List<String>.from(comments[commentIndex]['likes']);
        }
      }

      update();
    } catch (e) {
      print("Error liking comment: $e");
      rethrow;
    }
  }

  /// Private function to upload video to Firebase Storage
  Future<String> _uploadVideoToStorage(String videoId, File videoFile) async {
    try {
      Reference ref = _storage.ref().child('videos').child('$videoId.mp4');
      UploadTask uploadTask = ref.putFile(videoFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
      //  return (await FileUploadingService().uploadVideo(videoFile))!;
    } catch (e) {
      print("Error uploading video to storage: $e");
      rethrow;
    }
  }

  Future<String> _uploadVideoThumnailToStorage(
      String videoId, File thumbnail) async {
    try {
      Random rnd = Random();
      Reference ref = _storage
          .ref()
          .child('thumnails')
          .child('${rnd.nextInt(345345)}$videoId.png');
      UploadTask uploadTask = ref.putFile(thumbnail);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
      //  return (await FileUploadingService().uploadImage(thumbnail))!;
    } catch (e) {
      print("Error uploading thumbnail to storage: $e");
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

  @override
  void onInit() {
    fetchAllVideos();
    super.onInit();
  }
}
