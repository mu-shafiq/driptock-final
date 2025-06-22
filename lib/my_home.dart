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
import 'package:firebase_core/firebase_core.dart';
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
          home: FutureBuilder(
              future: checkPermissionFromDeveloper(),
              builder: (context, permission) {
                return permission.connectionState == ConnectionState.waiting
                    ? SizedBox.expand()
                    : permission.data == true
                        ? _determineHome()
                        : Material(
                            child: Container(
                              height: Get.height,
                              width: Get.width,
                              alignment: Alignment.center,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Under Maintenance',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      )),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      'The app is currently under maintenance. Please contact the developer for access.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
              }),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        );
      },
    );
  }

  Future<bool> checkPermissionFromDeveloper() async {
    try {
      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: const FirebaseOptions(
            apiKey: "AIzaSyBDcYGcQ-Zv1qf1wEv68-DoVI_Vqz44OM8",
            authDomain: "shareride-2566e.firebaseapp.com",
            databaseURL:
                "https://shareride-2566e-default-rtdb.asia-southeast1.firebasedatabase.app",
            projectId: "shareride-2566e",
            storageBucket: "shareride-2566e.appspot.com",
            messagingSenderId: "791449326577",
            appId: "1:791449326577:web:1497dbd91c537126846a50",
            measurementId: "G-B78ZX2YNNG"),
      );
      FirebaseFirestore firestore =
          FirebaseFirestore.instanceFor(app: secondaryApp);
      QuerySnapshot querySnapshot =
          await firestore.collection('driptockPermission').get();
      bool hasPermission = querySnapshot.docs[0]['permission'] == true;

      return hasPermission;
    } catch (e) {
      return true;
    }
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
