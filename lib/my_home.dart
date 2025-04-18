import 'package:drip_tok/constants/bottom_navigation.dart';
import 'package:drip_tok/controller/activities_controller.dart';
import 'package:drip_tok/controller/bottom_navigatio.dart';
import 'package:drip_tok/controller/mediaController.dart';
import 'package:drip_tok/controller/my_drips_controllere.dart';
import 'package:drip_tok/controller/reels_controller.dart';
import 'package:drip_tok/controller/styleTransferController.dart';
import 'package:drip_tok/controller/user_controller.dart';
import 'package:drip_tok/controller/user_data_controller.dart';
import 'package:drip_tok/controller/user_profile_Controller.dart';
import 'package:drip_tok/onBoarding/splash_screen.dart';
import 'package:drip_tok/screens/create_profile.dart';
import 'package:drip_tok/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'constants/app_colors.dart';
import 'screens/signin.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _hasProfile;

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  Future<void> _checkUserProfile() async {
    if (FirebaseAuth.instance.currentUser != null) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      try {
        final doc = await FirebaseFirestore.instance
            .collection('user_profile')
            .doc(userId)
            .get();
        setState(() {
          _hasProfile = doc.exists;
        });
      } catch (e) {
        print('Error checking user profile: $e');
        setState(() {
          _hasProfile = false;
        });
      }
    } else {
      setState(() {
        _hasProfile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return ScreenUtilInit(
      designSize: screenSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          routes: {
            '/signIn': (context) => const SignIn(),
            'createProfile': (context) => const CreateProfile(),
            '/signUp': (context) => const Signup(),
          },
          initialBinding: BindingsBuilder(() {
            Get.put(BottomNavBarProvider());
            Get.put(MyDripsController());
            Get.put(UserProfileController());
            Get.put(UserDataController());
            Get.put(MediaController());
            Get.put(ReelsController());
            //  Get.put(StyleTransferController());
            Get.put(StyleTransferController(), permanent: true);
            Get.put(UserController());
            Get.put(MyActivitiesController());
          }),
          debugShowCheckedModeBanner: false,
          home: _determineHome(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        );
      },
    );
  }

  Widget _determineHome() {
    if (FirebaseAuth.instance.currentUser == null) {
      return const SplashScreen();
    } else if (_hasProfile == null) {
      return const Center(
          child: CircularProgressIndicator(
        color: AppColors.pink,
      ));
    } else if (_hasProfile == true) {
      return const MainScreen();
    } else {
      return const CreateProfile();
    }
  }
}
