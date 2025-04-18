import 'dart:io';

import 'package:drip_tok/Utils/app_utils.dart';
import 'package:drip_tok/model/user_model.dart';
import 'package:drip_tok/screens/create_profile.dart';
import 'package:drip_tok/screens/signin.dart';
import 'package:drip_tok/screens/terms_conditions.dart';
import 'package:drip_tok/services/auth_services.dart';
import 'package:drip_tok/services/firestore_Services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import '../widgets/custom_appname.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_divider.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_textfield.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});
  @override
  State<Signup> createState() => _SignupState();
}

final ValueNotifier<bool> _isPasswordVisible = ValueNotifier<bool>(false);
final ValueNotifier<bool> _isPasswordVisibility = ValueNotifier<bool>(false);

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  bool _isCheckboxValid = false;

  bool _isLoading = false;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bglight, AppColors.bgdark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.15.h),
                        Align(
                          alignment: Alignment.center,
                          child: AppName(
                            fontSize: 35.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: height * 0.05.h),
                        CustomText(
                          title: 'Sign up',
                          color: Colors.white,
                          size: 19.sp,
                          fontFamily: 'Inter',
                          weight: FontWeight.w700,
                        ),
                        CustomText(
                          title: 'Enter your details for sign up',
                          color: Colors.white,
                          fontFamily: 'Inter',
                          size: 13.sp,
                          weight: FontWeight.w500,
                        ),
                        SizedBox(height: height * 0.02.h),
                        CustomText(
                          title: 'Email Address',
                          color: Colors.white,
                          fontFamily: 'Inter',
                          size: 13.sp,
                          weight: FontWeight.w500,
                        ),
                        SizedBox(height: height * 0.01.h),
                        CustomTextField(
                          prefixSvgIconPath: AppSvgs.email,
                          hintText: 'Email Address',
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            final emailRegex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.02.h),
                        CustomText(
                          title: 'Password',
                          color: Colors.white,
                          fontFamily: 'Inter',
                          size: 13.sp,
                          weight: FontWeight.w500,
                        ),
                        SizedBox(height: height * 0.01.h),
                        ValueListenableBuilder<bool>(
                          valueListenable: _isPasswordVisible,
                          builder: (context, isPasswordVisible, child) {
                            return CustomTextField(
                              prefixSvgIconPath: AppSvgs.password,
                              suffixSvgIconPath: isPasswordVisible
                                  ? AppSvgs.eye
                                  : AppSvgs.eye_off,
                              hintText: 'Create Password',
                              obscureText: !isPasswordVisible,
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                              onSuffixIconTap: () {
                                _isPasswordVisible.value =
                                    !_isPasswordVisible.value;
                              },
                            );
                          },
                        ),
                        SizedBox(height: height * 0.02.h),
                        CustomText(
                          title: 'Confirm Password',
                          color: Colors.white,
                          fontFamily: 'Inter',
                          size: 13.sp,
                          weight: FontWeight.w500,
                        ),
                        SizedBox(height: height * 0.01.h),
                        ValueListenableBuilder<bool>(
                          valueListenable: _isPasswordVisibility,
                          builder: (context, isPasswordVisibility, child) {
                            return CustomTextField(
                              prefixSvgIconPath: AppSvgs.password,
                              suffixSvgIconPath: isPasswordVisibility
                                  ? AppSvgs.eye
                                  : AppSvgs.eye_off,
                              hintText: 'Confirm Password',
                              obscureText: !isPasswordVisibility,
                              controller: _confirmPasswordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              onSuffixIconTap: () {
                                _isPasswordVisibility.value =
                                    !_isPasswordVisibility.value;
                              },
                            );
                          },
                        ),
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isCheckboxValid = !_isCheckboxValid;
                                });
                              },
                              child: Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  color: _isCheckboxValid
                                      ? AppColors.pink
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: _isCheckboxValid
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(
                              width: width * 0.02,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Get.to(TermsAndConditionsPage());
                                    },
                                    child: const Row(
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'I hereby agree to ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Terms and Condition',
                                                style: TextStyle(
                                                  color: AppColors.pink,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: height * 0.05.h,
                        ),
                        SizedBox(height: height * 0.05.h),
                        SizedBox(
                          width: width * 0.9,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: loading,
                            builder: (context, isLoading, child) {
                              return CustomButton(
                                loading: isLoading,
                                text: 'Sign up',
                                textSize: 14,
                                textColor: Colors.white,
                                fontWeight: FontWeight.w600,
                                onPressed: () async {
                                  if (!_isCheckboxValid) {
                                    AppUtils.toastMessage(
                                        'Please agree to the terms and conditions.');
                                    return;
                                  }
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    loading.value = true;

                                    try {
                                      var userCredentials =
                                          await AuthServices.signUp(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                        context: context,
                                      );

                                      if (userCredentials != null) {
                                        User? user =
                                            FirebaseAuth.instance.currentUser;

                                        if (user != null) {
                                          String userID = user.uid;

                                          UserModel userModel = UserModel(
                                            email: _emailController.text,
                                            userId: userID,
                                          );

                                          await FirestoreServices
                                              .uploadUserData(
                                            usermodel: userModel,
                                            docId: userID,
                                          );

                                          AppUtils.toastMessage(
                                              'Account created successfully');

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const CreateProfile(),
                                            ),
                                          );
                                        } else {
                                          AppUtils.toastMessage(
                                              "Something went wrong. Please try again.");
                                        }
                                      }
                                    } catch (e) {
                                      print("Error signing up: $e");
                                      AppUtils.toastMessage(
                                          "Error signing up. Please try again.");
                                    } finally {
                                      loading.value = false;
                                    }
                                  } else {
                                    AppUtils.toastMessage(
                                        "Passwords do not match.");
                                    loading.value = false;
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: height * 0.03.h),
                        const GradientDivider(
                          dividerWidth: 100,
                          dividerHeight: 1,
                          text: 'OR',
                          leftColor: AppColors.dividerGradeint,
                          rightColor: AppColors.dividerGradeint,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Platform.isIOS
                                ? GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      await AuthServices
                                          .signInOrSignUpWithApple(context);
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    },
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            backgroundColor: AppColors.pink,
                                          )
                                        : Image.asset(
                                            AppImages.apple,
                                            width: width * 0.13,
                                            height: height * 0.13,
                                          ),
                                  )
                                : const SizedBox.shrink(),
                            SizedBox(
                              width: Platform.isIOS ? width * 0.05 : 0,
                            ),
                            Platform.isAndroid
                                ? InkWell(
                                    onTap: () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      await AuthServices
                                          .signInOrSignUpWithGoogle(context);
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    },
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            backgroundColor: AppColors.pink,
                                          )
                                        : Image.asset(
                                            AppImages.google,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.13,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.13,
                                          ),
                                  )
                                : const SizedBox.shrink()
                          ],
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return const SignIn();
                                },
                              ));
                            },
                            child: const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      color: AppColors.pink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.03.h),
                      ]),
                ),
              ),
            ),
          )),
    );
  }
}
