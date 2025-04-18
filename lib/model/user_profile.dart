// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserProfile {
  final String? userId;
  final String? email;

  final String? displayname;
  final String? username;
  final String? bio;
  final String? gender;
  final String? age;
  final String? image;
  List<String>? savedDrips;
  List<String>? followers;
  List<String>? followings;

  UserProfile(
      {this.userId,
      this.email,
      this.displayname,
      this.username,
      this.image,
      this.bio,
      this.gender,
      this.age,
      this.followers,
      this.followings,
      this.savedDrips});
  UserProfile copyWith({
    String? displayname,
    String? username,
    String? bio,
    String? image,
    List<String>? savedDrips,
    List<String>? followers,
    List<String>? followings,
  }) {
    return UserProfile(
      displayname: displayname ?? this.displayname,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'email': email,
      'displayname': displayname,
      'username': username,
      'bio': bio,
      'gender': gender,
      'age': age,
      'image': image,
      'savedDrips': savedDrips,
      'followers': followers,
      'followings': followings,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
        userId: map['userId'] != null ? map['userId'] as String : null,
        email: map['email'] != null ? map['email'] as String : null,
        displayname:
            map['displayname'] != null ? map['displayname'] as String : null,
        username: map['username'] != null ? map['username'] as String : null,
        bio: map['bio'] != null ? map['bio'] as String : null,
        gender: map['gender'] != null ? map['gender'] as String : null,
        age: map['age'] != null ? map['age'] as String : null,
        savedDrips: List.from(map['savedDrips'] ?? []),
        followers: List.from(map['followers'] ?? []),
        followings: List.from(map['followings'] ?? []),
        image: map['image'] != null ? map['image'] as String : null);
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, displayname: $displayname, username: $username, bio: $bio, gender: $gender, age: $age, image: $image)';
  }
}
