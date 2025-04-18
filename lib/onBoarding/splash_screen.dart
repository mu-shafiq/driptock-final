import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/onBoarding/on_boarding1.dart';
import 'package:drip_tok/widgets/custom_appname.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Utils/fade_transition.dart';
import '../bottom_navigation/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.splashscreen),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(AppImages.boardingShades),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppName(
                    fontSize: 57.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomText(
                    title: 'For Men, Women & Kids',
                    color: Colors.white,
                    size: 20.sp,
                    fontFamily: 'Inter',
                    weight: FontWeight.w500,
                  ),
                  SizedBox(height: height * 0.03),
                  GestureDetector(
                    onTap: () {
                      navigateWithFadeFromBack(context, OnBoarding1());
                    },
                    child: Image.asset(
                      AppImages.next,
                      height: height * 0.13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
