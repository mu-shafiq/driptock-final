import 'package:drip_tok/Utils/fade_transition.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/onBoarding/onboarding3.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OnBoarding2 extends StatefulWidget {
  const OnBoarding2({super.key});

  @override
  State<OnBoarding2> createState() => _OnBoarding2State();
}

class _OnBoarding2State extends State<OnBoarding2> {
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
                  image: AssetImage(AppImages.onBoarding2),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(AppImages.boardingShades),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height * 0.12,
                width: width,
                decoration: const BoxDecoration(
                  color: Color(0xFF212f50),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: width * 0.03,
                            height: width * 0.03,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: index == 1
                                      ? Colors.white
                                      : Colors.transparent),
                              shape: BoxShape.circle,
                              color:
                                  index == 1 ? Colors.transparent : Colors.grey,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (index == 1)
                                  Container(
                                    width: width * 0.015,
                                    height: width * 0.015,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            navigateWithFadeFromBack(context, Onboarding3());
                          },
                          child: Container(
                            height: height * 0.06,
                            width: width * 0.4,
                            decoration: BoxDecoration(
                              color: AppColors.pink,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  title: 'Continue',
                                  color: Colors.white,
                                  size: 16.sp,
                                  fontFamily: 'Poppins',
                                  weight: FontWeight.w700,
                                ),
                                SizedBox(
                                  width: width * 0.02,
                                ),
                                Image.asset(AppImages.continueArrow,
                                    height: height * 0.0124),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    EdgeInsets.only(bottom: height * 0.15, right: width * 0.1),
                child: SizedBox(
                  width: .8.sw,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        title: 'Create',
                        color: Colors.white,
                        size: 25.sp,
                        fontFamily: 'Poppins',
                        weight: FontWeight.w700,
                      ),
                      SizedBox(height: 5.h),
                      CustomText(
                        title:
                            'Create and share your drip ideas with\nyour friends and peers',
                        color: Colors.white,
                        size: Get.width < 320 ? null : 16.sp,
                        fontFamily: 'Poppins',
                        weight: FontWeight.w300,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
