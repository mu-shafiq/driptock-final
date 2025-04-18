import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_profile.dart';

class CommentModel {
  final String commentId;
  final String userId;
  final String comment;
  List<String> likes;
  final DateTime createdAt;
  UserProfile? user;
  List<ReplyModel> replies;
  CommentModel({
    required this.commentId,
    required this.userId,
    required this.comment,
    required this.likes,
    required this.createdAt,
    this.user,
    this.replies = const [],
  });
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'],
      userId: map['userId'],
      comment: map['comment'],
      likes: List<String>.from(map['likes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      replies: map['replies'] != null
          ? List<ReplyModel>.from(
              map['replies'].map((x) => ReplyModel.fromMap(x)))
          : [],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'userId': userId,
      'comment': comment,
      'likes': likes,
      'createdAt': createdAt,
      'replies': replies.map((x) => x.toMap()).toList(),
    };
  }

  void addReply(ReplyModel reply) {
    replies.add(reply);
  }
}

class ReplyModel {
  final String replyId;
  final String userId;
  final String replyusername;
  final String replyText;
  final DateTime createdAt;
  UserProfile? user;
  ReplyModel({
    required this.replyId,
    required this.userId,
    required this.replyText,
    required this.createdAt,
    required this.replyusername,
    this.user,
  });
  factory ReplyModel.fromMap(Map<String, dynamic> map) {
    return ReplyModel(
      replyId: map['replyId'],
      userId: map['userId'],
      replyText: map['replyText'],
      replyusername: map['replyusername'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'replyId': replyId,
      'userId': userId,
      'replyText': replyText,
      'createdAt': createdAt,
      'replyusername': replyusername,
    };
  }
}
