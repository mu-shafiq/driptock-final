import 'dart:developer';

import 'package:drip_tok/Utils/app_utils.dart';

import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/bottom_navigation.dart';

import 'package:drip_tok/controller/reels_controller.dart';
import 'package:drip_tok/model/user_model.dart';
import 'package:drip_tok/model/user_profile.dart';

import 'package:drip_tok/services/firestore_Services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../controller/user_data_controller.dart';
import '../controller/user_profile_Controller.dart';

class AuthServices {
  static Future<UserCredential?> signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
          .hasMatch(email)) {
        AppUtils.toastMessage('Please enter a valid email address');
        return null;
      }
      log('Attempting to sign up with email: $email');

      final credentials =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credentials.user != null) {
        log('Signup successful for user: ${credentials.user?.email}');

        Get.find<UserDataController>().fetchUserData();

        //  await Get.delete<UserProfileController>();
        Get.find<UserProfileController>().fetchUserProfile();
        // await Get.delete<ReelsController>();
        // Get.put(ReelsController());

        return credentials;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        AppUtils.toastMessage(
            'Weak password, please use at least 6 characters');
      } else if (e.code == 'email-already-in-use') {
        AppUtils.toastMessage('Email is already in use, try a different one');
      } else if (e.code == 'invalid-email') {
        AppUtils.toastMessage('The email address is not valid');
      } else {
        AppUtils.toastMessage('Error: ${e.message}');
      }
    } catch (e) {
      log('Unexpected error: ${e.toString()}');
      AppUtils.toastMessage('An unexpected error occurred: ${e.toString()}');
    }

    return null;
  }

  static Future<UserCredential> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final credentials =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credentials.user != null) {
        //  await Get.delete<UserDataController>();
        Get.find<UserDataController>().fetchUserData();

        //  await Get.delete<UserProfileController>();
        Get.find<UserProfileController>().fetchUserProfile();
        // await Get.delete<ReelsController>();

        // Get.put(ReelsController());

        return credentials;
      } else {
        throw FirebaseAuthException(
          code: 'login-failed',
          message: 'Login failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.message}");
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password provided.';
      } else {
        errorMessage = 'Login failed. Please try again.';
      }
      throw FirebaseAuthException(
        code: e.code,
        message: errorMessage,
      );
    } catch (e) {
      debugPrint("Unexpected error: ${e.toString()}");
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  static Future<void> logOut(BuildContext context) async {
    Get.put(UserDataController());
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/signIn',
      (Route<dynamic> route) => false,
    );
  }

  static Future<void> signInOrSignUpWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint("User cancelle Google Sign-In");
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.additionalUserInfo!.isNewUser) {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          String userID = user.uid;

          UserModel userModel = UserModel(
            email: userCredential.user!.email,
            userId: userID,
          );

          await FirestoreServices.uploadUserData(
            usermodel: userModel,
            docId: userID,
          );
          UserProfile model = UserProfile(
            age: '20',
            bio: '',
            displayname: userCredential.user!.displayName,
            username:
                userCredential.user!.displayName?.replaceAll(' ', '') ?? '',
            gender: 'Male'!,
            image: userCredential.user!.photoURL,
            userId: userID,
          );
          await FirestoreServices.uploadProfileData(
            userprofile: model,
            docId: userID,
          );
        }
      }

      Get.find<UserDataController>().fetchUserData();

      //  await Get.delete<UserProfileController>();
      Get.find<UserProfileController>().fetchUserProfile();

      debugPrint("Google Sign-In successful!");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ));
    } catch (e) {
      Get.snackbar(
        'Ohhhhhh',
        'Unable to proceed',
        backgroundColor: AppColors.pink,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  static Future<void> signInOrSignUpWithApple(BuildContext context) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      if (userCredential.additionalUserInfo!.isNewUser) {
        if (appleCredential.email == null || appleCredential.email!.isEmpty) {
          Get.snackbar("Error", "Email is empty.",
              backgroundColor: AppColors.pink, colorText: Colors.white);
          return;
        }
        if ((appleCredential.givenName == null ||
                appleCredential.givenName!.isEmpty) &&
            (appleCredential.familyName == null ||
                appleCredential.familyName!.isEmpty)) {
          Get.snackbar("Error", "Name is empty.",
              backgroundColor: AppColors.pink, colorText: Colors.white);
          return;
        }

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String userID = user.uid;

          String email = userCredential.user!.email ?? appleCredential.email!;

          final String displayName =
              "${appleCredential.givenName ?? 'Driptock'} ${appleCredential.familyName ?? 'User'}"
                  .trim();
          final String username = displayName.replaceAll(' ', '').toLowerCase();

          UserModel userModel = UserModel(
            email: email,
            userId: userID,
          );
          await FirestoreServices.uploadUserData(
              usermodel: userModel, docId: userID);
          UserProfile model = UserProfile(
            age: '20',
            bio: '',
            email: email,
            displayname: displayName,
            username: username,
            gender: 'Male',
            image: userCredential.user!.photoURL ?? "",
            userId: userID,
          );
          await FirestoreServices.uploadProfileData(
              userprofile: model, docId: userID);
        } else {}
      } else {
        debugPrint("Existing user.");
      }
      Get.find<UserDataController>().fetchUserData();
      Get.find<UserProfileController>().fetchUserProfile();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      debugPrint("Error during sign-in: $e");
      Get.snackbar('Ohhhhhh', 'Unable to proceed',
          backgroundColor: AppColors.pink, colorText: Colors.white);
      rethrow;
    }
  }
}
