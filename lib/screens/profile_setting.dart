import 'dart:ui';

import 'package:drip_tok/Utils/share_app.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/screens/edit_profile_setting.dart';
import 'package:drip_tok/screens/feedback.dart';
import 'package:drip_tok/screens/help_support.dart';
import 'package:drip_tok/services/auth_services.dart';
import 'package:drip_tok/widgets/custom_button.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../controller/user_profile_Controller.dart';

class ProfileSetting extends StatefulWidget {
  const ProfileSetting({super.key});
  @override
  State<ProfileSetting> createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  Future<void> deleteAccount() async {
    await deleteUser(context);
    Get.snackbar('Delete Account', 'Your account deleted successfully',
        backgroundColor: AppColors.pink, colorText: Colors.white);
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/signUp',
      (Route<dynamic> route) => false,
    );
  }

  Future<void> reauthenticateUser(String email, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);
        print("User re-authenticated successfully.");

        await deleteUser(context);
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print("Re-authentication failed: $e");
    }
  }

  Future<void> deleteUser(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        Get.snackbar("Need to authenticate account ",
            "You need to log in again to delete your account.",
            backgroundColor: AppColors.pink, colorText: Colors.white);
      } else {
        print("Failed to delete user: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bglight, AppColors.bgdark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 80),
          child: SingleChildScrollView(
            child: Obx(
              () {
                final userProfile =
                    Get.find<UserProfileController>().profileModel.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: height * 0.035,
                            width: width * 0.08,
                            decoration: BoxDecoration(
                                color: AppColors.bglight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white)),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: SvgPicture.asset(
                                AppSvgs.arrowback,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: width * 0.05,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 60),
                          child: CustomText(
                            title: 'Profile Settings',
                            color: Colors.white,
                            size: 18.sp,
                            fontFamily: 'Poppins',
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.03.h,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileSetting(
                                  username: userProfile.username ?? '',
                                  displayName: userProfile.displayname ?? '',
                                  bio: userProfile.bio ?? '',
                                ),
                              ));
                        },
                        child: ClipOval(
                          child: Image.network(
                            userProfile.image ?? '',
                            height: height * 0.1,
                            width: height * 0.1,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              AppImages.profile,
                              height: height * 0.1,
                              width: height * 0.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.04.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileSetting(
                                username: userProfile.username ?? '',
                                displayName: userProfile.displayname ?? '',
                                bio: userProfile.bio ?? '',
                              ),
                            ));
                      },
                      child: Container(
                        height: height * 0.065,
                        width: width * 0.9,
                        decoration: BoxDecoration(
                            color: AppColors.textFieledfillColor,
                            borderRadius: BorderRadius.circular(35),
                            border:
                                Border.all(color: AppColors.textfieledBorder)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: [
                              SvgPicture.asset(AppSvgs.profile),
                              SizedBox(
                                width: width * 0.03,
                              ),
                              CustomText(
                                title: 'Personal Setting',
                                color: AppColors.gray,
                                size: 13.sp,
                                fontFamily: 'Poppins',
                                weight: FontWeight.w500,
                              ),
                              Spacer(),
                              SvgPicture.asset(
                                AppSvgs.arrow_forward,
                                height: height * 0.025,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Feedbackk(),
                            ));
                      },
                      child: Container(
                        height: height * 0.065,
                        width: width * 0.9,
                        decoration: BoxDecoration(
                            color: AppColors.textFieledfillColor,
                            borderRadius: BorderRadius.circular(35),
                            border:
                                Border.all(color: AppColors.textfieledBorder)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: [
                              SvgPicture.asset(AppSvgs.feedback),
                              SizedBox(
                                width: width * 0.03,
                              ),
                              CustomText(
                                title: 'Give feedback us',
                                color: AppColors.gray,
                                size: 13.sp,
                                fontFamily: 'Poppins',
                                weight: FontWeight.w500,
                              ),
                              Spacer(),
                              SvgPicture.asset(
                                AppSvgs.arrow_forward,
                                height: height * 0.025,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015.h,
                    ),
                    Builder(
                      builder: (BuildContext innerContext) {
                        return InkWell(
                          onTap: () {
                            shareLink(
                                'Check out this amazing app:\nDripTok! https://driptock.com',
                                innerContext);
                          },
                          child: Container(
                            height: height * 0.065,
                            width: width * 0.9,
                            decoration: BoxDecoration(
                                color: AppColors.textFieledfillColor,
                                borderRadius: BorderRadius.circular(35),
                                border: Border.all(
                                    color: AppColors.textfieledBorder)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                children: [
                                  SvgPicture.asset(AppSvgs.invite),
                                  SizedBox(
                                    width: width * 0.03,
                                  ),
                                  CustomText(
                                    title: 'Invite Friends',
                                    color: AppColors.gray,
                                    size: 13.sp,
                                    fontFamily: 'Poppins',
                                    weight: FontWeight.w500,
                                  ),
                                  Spacer(),
                                  SvgPicture.asset(
                                    AppSvgs.arrow_forward,
                                    height: height * 0.025,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: height * 0.015.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupport(),
                            ));
                      },
                      child: Container(
                        height: height * 0.065,
                        width: width * 0.9,
                        decoration: BoxDecoration(
                            color: AppColors.textFieledfillColor,
                            borderRadius: BorderRadius.circular(35),
                            border:
                                Border.all(color: AppColors.textfieledBorder)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: [
                              SvgPicture.asset(AppSvgs.help),
                              SizedBox(
                                width: width * 0.03,
                              ),
                              CustomText(
                                title: 'Help and support',
                                color: AppColors.gray,
                                size: 13.sp,
                                fontFamily: 'Poppins',
                                weight: FontWeight.w500,
                              ),
                              Spacer(),
                              SvgPicture.asset(
                                AppSvgs.arrow_forward,
                                height: height * 0.025,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await launchUrl(Uri.parse(
                            'https://www.termsfeed.com/live/d259b8eb-9e1f-4003-ad97-df5de8153132'));
                      },
                      child: Container(
                        height: height * 0.065,
                        width: width * 0.9,
                        decoration: BoxDecoration(
                            color: AppColors.textFieledfillColor,
                            borderRadius: BorderRadius.circular(35),
                            border:
                                Border.all(color: AppColors.textfieledBorder)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: [
                              Icon(
                                Icons.privacy_tip,
                                color: Colors.white.withOpacity(.4),
                              ),
                              SizedBox(
                                width: width * 0.03,
                              ),
                              CustomText(
                                title: 'Privacy Policy',
                                color: AppColors.gray,
                                size: 13.sp,
                                fontFamily: 'Poppins',
                                weight: FontWeight.w500,
                              ),
                              Spacer(),
                              SvgPicture.asset(
                                AppSvgs.arrow_forward,
                                height: height * 0.025,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDeleteDialog(context);
                      },
                      child: Container(
                        height: height * 0.065,
                        width: width * 0.9,
                        decoration: BoxDecoration(
                            color: AppColors.textFieledfillColor,
                            borderRadius: BorderRadius.circular(35),
                            border:
                                Border.all(color: AppColors.textfieledBorder)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                title: 'Delete Account',
                                color: AppColors.gray,
                                size: 13.sp,
                                fontFamily: 'Poppins',
                                weight: FontWeight.w500,
                              ),
                              SvgPicture.asset(
                                AppSvgs.arrow_forward,
                                height: height * 0.025,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        showLogoutDialog(context);
                      },
                      child: Container(
                        height: height * 0.065,
                        width: width * 0.9,
                        decoration: BoxDecoration(
                            color: AppColors.textFieledfillColor,
                            borderRadius: BorderRadius.circular(35),
                            border:
                                Border.all(color: AppColors.textfieledBorder)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                title: 'Logout',
                                color: AppColors.orange,
                                size: 13.sp,
                                fontFamily: 'Poppins',
                                weight: FontWeight.w500,
                              ),
                              SvgPicture.asset(
                                AppSvgs.logout,
                                color: AppColors.orange,
                                height: height * 0.025,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  showDeleteDialog(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    FirebaseAuth auth = FirebaseAuth.instance;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              content: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 20,
                  bottom: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 130.h,
                      width: 130.w,
                      child: Image.asset(AppImages.delete),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText(
                        title: 'Do you want to delete Account?',
                        fontFamily: 'Poppins',
                        weight: FontWeight.w400,
                        size: 13.sp,
                        color: AppColors.midNight,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: SizedBox(
                            width: 0.4.sw,
                            child: CustomButton1(
                              textColor: AppColors.pink,
                              backgroundColor: AppColors.babypink,
                              borderColor: AppColors.pink,
                              text: 'No',
                              textSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Flexible(
                          child: SizedBox(
                            width: 0.4.sw,
                            child: CustomButton(
                              text: 'Yes',
                              textSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              onPressed: () async {
                                Navigator.pop(context);
                                await deleteAccount();
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

showLogoutDialog(BuildContext context) {
  var size = MediaQuery.of(context).size;
  double width = size.width;
  double height = size.height;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            content: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                top: 20,
                bottom: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 130.h,
                    width: 130.w,
                    child: Image.asset(AppImages.logout),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: CustomText(
                      title: 'Are you sure you want to log out?',
                      fontFamily: 'Poppins',
                      weight: FontWeight.w400,
                      size: 13.sp,
                      color: AppColors.midNight,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: SizedBox(
                          width: 0.4.sw,
                          child: CustomButton1(
                            textColor: AppColors.pink,
                            backgroundColor: AppColors.babypink,
                            borderColor: AppColors.pink,
                            text: 'No',
                            textSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Flexible(
                        child: SizedBox(
                          width: 0.4.sw,
                          child: CustomButton(
                            text: 'Yes',
                            textSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            onPressed: () {
                              AuthServices.logOut(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
