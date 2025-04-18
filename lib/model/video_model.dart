import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drip_tok/model/comment_model.dart';
import 'package:drip_tok/model/user_profile.dart';

/// Video Model Class
class VideoModel {
  final String videoId;
  final String description;
  final String userId;
  final String userName;
  final String userImage;
  final int? index;
  final String videoUrl;
  final bool isPhoto;
  final List<String> likes;
  final Timestamp createdAt;
  List<CommentModel> comments;

  List<String>? savedBy;
  String? thumbnail;

  VideoModel({
    required this.videoId,
    required this.description,
    required this.userId,
    required this.videoUrl,
    required this.likes,
    required this.isPhoto,
    required this.userName,
    required this.userImage,
    this.index,
    required this.createdAt,
    required this.comments,
    this.savedBy,
    this.thumbnail,
  });

  factory VideoModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return VideoModel(
      videoId: map['videoId'],
      description: map['description'],
      userId: map['userId'],
      userName: map['userName'] ?? "Driptock user",
      userImage: map['userImage'] ?? "",
      videoUrl: map['videoUrl'],
      isPhoto: map['isPhoto'] ?? false,
      thumbnail: map['thumbnail'] ?? '',
      savedBy: List.from(map['savedBy'] ?? []),
      likes: List<String>.from(map['likes'] ?? []),
      createdAt: map['createdAt'] == null
          ? Timestamp.fromDate(DateTime.now().subtract(Duration(days: 4)))
          : map['createdAt'] as Timestamp,
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((c) => CommentModel.fromMap(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'description': description,
      'userId': userId,
      'userImage': userImage,
      'userName': userName,
      'videoUrl': videoUrl,
      'isPhoto': isPhoto,
      'thumbnail': thumbnail,
      'likes': likes,
      'createdAt': Timestamp.now(),
      'comments': comments.map((c) => c.toMap()).toList(),
      'savedBy': savedBy
    };
  }
}
