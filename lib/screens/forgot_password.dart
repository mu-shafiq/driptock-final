import 'dart:ui';

import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/screens/signin.dart';
import 'package:drip_tok/widgets/custom_textfield.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    if (!regex.hasMatch(value)) {
      return 'Please enter valid email';
    }
    return null;
  }

  Future<void> _sendPasswordResetLink() async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 80.h),
          child: Column(
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
                        border: Border.all(color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(AppSvgs.arrowback),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.05),
                  CustomText(
                    title: 'Forgot password',
                    color: Colors.white,
                    size: 17.sp,
                    fontFamily: 'Poppins',
                    weight: FontWeight.w700,
                  ),
                ],
              ),
              SizedBox(height: height * 0.05),
              CustomText(
                title: 'Email Address',
                color: Colors.white,
                fontFamily: 'Inter',
                size: 13.sp,
                weight: FontWeight.w500,
              ),
              SizedBox(height: height * 0.01.h),
              Form(
                key: _formKey,
                child: CustomTextField(
                  controller: emailController,
                  prefixSvgIconPath: AppSvgs.email,
                  hintText: 'Email Address',
                  validator: _validateEmail,
                ),
              ),
              SizedBox(height: height * 0.02),
              SvgPicture.asset(AppSvgs.steric),
              SizedBox(height: height * 0.06),
              SizedBox(
                width: width * 0.9.w,
                child: CustomButton(
                  text: 'Submit',
                  textSize: 14,
                  fontWeight: FontWeight.w600,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      email = emailController.text.trim();
                      sendPasswordLinkDialog(context);
                      _sendPasswordResetLink();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  sendPasswordLinkDialog(BuildContext context) {
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
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
                      child: Image.asset(AppImages.updated),
                    ),
                    CustomText(
                      title: 'Password reset link sent to email',
                      fontFamily: 'Poppins',
                      weight: FontWeight.w400,
                      size: 14.sp,
                      color: AppColors.midNight,
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    SizedBox(
                      width: width * 0.9.w,
                      child: CustomButton(
                        text: 'Okay',
                        textSize: 16,
                        fontWeight: FontWeight.w600,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignIn(),
                              ));
                        },
                      ),
                    ),
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
