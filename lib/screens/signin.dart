import 'dart:io';

import 'package:drip_tok/constants/bottom_navigation.dart';
import 'package:drip_tok/screens/signup.dart';
import 'package:drip_tok/screens/terms_conditions.dart';
import 'package:drip_tok/services/auth_services.dart';
import 'package:drip_tok/widgets/custom_button.dart';
import 'package:drip_tok/widgets/custom_divider.dart';
import 'package:drip_tok/screens/forgot_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/widgets/custom_appname.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:drip_tok/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Utils/app_utils.dart';
import '../constants/app_colors.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});
  @override
  State<SignIn> createState() => _SignInState();
}

final ValueNotifier<bool> _isPasswordVisible = ValueNotifier<bool>(false);

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  bool _isLoading = false;
  bool _isCheckboxValid = false;

  @override
  void initState() {
    requestPermissions();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> requestPermissions() async {
    List<Permission> permissions = [
      Permission.camera,
      Permission.microphone,
    ];

    if (Platform.isAndroid) {
      permissions.addAll([
        Permission.photos,
        Permission.videos,
        Permission.audio,
        Permission.accessMediaLocation,
      ]);
    } else if (Platform.isIOS) {
      permissions.addAll([
        Permission.photos,
        Permission.mediaLibrary,
      ]);
    }

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    statuses.forEach((permission, status) {
      debugPrint('$permission: $status');
    });

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      debugPrint("Permissions not granted. Cannot access photos or videos.");
    } else {
      debugPrint("All required permissions are granted.");
    }
  }

  void _launchURL() async {
    const url = 'https://www.google.com';

    await launch(url);
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
          height: double.infinity,
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
                    SizedBox(
                      height: height * 0.15.h,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: AppName(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.05.h,
                    ),
                    CustomText(
                      title: 'Sign In',
                      color: Colors.white,
                      size: 19.sp,
                      fontFamily: 'Inter',
                      weight: FontWeight.w700,
                    ),
                    CustomText(
                      title: 'Enter your details for sign in',
                      color: Colors.white,
                      fontFamily: 'Inter',
                      size: 13.sp,
                      weight: FontWeight.w500,
                    ),
                    SizedBox(
                      height: height * 0.02.h,
                    ),
                    CustomText(
                      title: 'Email Address',
                      color: Colors.white,
                      fontFamily: 'Inter',
                      size: 13.sp,
                      weight: FontWeight.w500,
                    ),
                    SizedBox(
                      height: height * 0.01.h,
                    ),
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
                          suffixSvgIconPath:
                              isPasswordVisible ? AppSvgs.eye : AppSvgs.eye_off,
                          hintText: 'Password',
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
                    SizedBox(
                      height: height * 0.01.h,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const ForgotPassword();
                            },
                          ));
                        },
                        child: CustomText(
                          title: 'Forgotten Password?',
                          color: AppColors.pink,
                          fontFamily: 'Poppins',
                          size: 13.sp,
                          weight: FontWeight.w300,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
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
                    SizedBox(
                        width: width * 0.9,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isLoading,
                          builder: (context, value, child) {
                            return CustomButton(
                              text: 'Sign In',
                              loading: value,
                              textSize: 14,
                              fontWeight: FontWeight.w600,
                              onPressed: () async {
                                if (!_isCheckboxValid) {
                                  AppUtils.toastMessage(
                                      'Please agree to the terms and conditions.');
                                  return;
                                }
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  isLoading.value = true;

                                  try {
                                    UserCredential? userCredentials =
                                        await AuthServices.signIn(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      context: context,
                                    );

                                    if (userCredentials != null) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MainScreen()),
                                      );
                                    } else {
                                      AppUtils.toastMessage(
                                          'Incorrect email or password');
                                    }
                                  } catch (e) {
                                    print("Error signing in: $e");
                                    AppUtils.toastMessage(
                                        'Invalid Credentials');
                                  } finally {
                                    isLoading.value = false;
                                  }
                                }
                              },
                            );
                          },
                        )),
                    SizedBox(
                      height: height * 0.03.h,
                    ),
                    const GradientDivider(
                      dividerWidth: 100,
                      dividerHeight: 1,
                      text: 'ORr',
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
                                  await AuthServices.signInOrSignUpWithApple(
                                      context);
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
                                  await AuthServices.signInOrSignUpWithGoogle(
                                      context);
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.13,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.13,
                                      ),
                              )
                            : const SizedBox.shrink()
                      ],
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Signup(),
                              ));
                        },
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'You don\'t have an account ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign Up?',
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
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
