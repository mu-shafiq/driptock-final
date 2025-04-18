// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String? email;
  final String? userId;

  UserModel({
    this.email,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'userId': userId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      userId: map['userId'] as String,
    );
  }
}
