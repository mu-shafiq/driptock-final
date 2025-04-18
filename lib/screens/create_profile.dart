import 'package:drip_tok/Utils/app_utils.dart';
import 'package:drip_tok/controller/image_picker_controller.dart';
import 'package:drip_tok/model/user_profile.dart';
import 'package:drip_tok/widgets/custom_genderselection.dart';
import 'package:drip_tok/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import '../constants/bottom_navigation.dart';
import '../services/firestore_Services.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});
  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

bool _isCheckboxValid = false;

class _CreateProfileState extends State<CreateProfile> {
  final TextEditingController _displaynameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isGenderValid = true;
  bool _isImageValid = true;
  String? _selectedGender;
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ProfileController profileController = Get.put(ProfileController());
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _displaynameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _launchURL() async {
    const url = 'https://www.google.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
              child: Form(
            key: _formKey,
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
                    CustomText(
                      title: 'Create Profile',
                      color: Colors.white,
                      size: 18.sp,
                      fontFamily: 'Poppins',
                      weight: FontWeight.w700,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: height * 0.2,
                        width: width * 0.25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textFieledfillColor,
                          border: Border.all(color: AppColors.textfieledBorder),
                        ),
                        child: Obx(() {
                          if (profileController.pickedImage.value != null) {
                            return Container(
                              height: height * 0.1,
                              width: height * 0.1,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                      profileController.pickedImage.value!),
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: SvgPicture.asset(
                                AppSvgs.addPicture,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            );
                          }
                        }),
                      ),
                      Positioned(
                        bottom: height * 0.04,
                        right: width * -0.04,
                        child: GestureDetector(
                          onTap: () {
                            profileController.pickImage();
                          },
                          child: SvgPicture.asset(AppSvgs.edit),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomText(
                  title: 'Display name',
                  color: Colors.white,
                  fontFamily: 'Inter',
                  size: 13.sp,
                  weight: FontWeight.w500,
                ),
                SizedBox(
                  height: height * 0.01.h,
                ),
                CustomTextField(
                  prefixSvgIconPath: AppSvgs.profile,
                  hintText: 'Display name',
                  controller: _displaynameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Display name cannot be empty.';
                    }
                    final trimmedValue = value.trim();
                    final regex = RegExp(r'^[a-zA-Z\s]+$');
                    if (!regex.hasMatch(trimmedValue)) {
                      return 'Please enter alphabetic characters ';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.02.h,
                ),
                CustomText(
                  title: 'Add username',
                  color: Colors.white,
                  fontFamily: 'Inter',
                  size: 13.sp,
                  weight: FontWeight.w500,
                ),
                SizedBox(
                  height: height * 0.01.h,
                ),
                CustomTextField(
                  controller: _usernameController,
                  prefixSvgIconPath: AppSvgs.profile,
                  hintText: 'Username',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username cannot be empty.';
                    }
                    final regex =
                        RegExp(r'^[a-zA-Z0-9!@#$%^&*()_+=[\]{}|;:,.<>?/-]*$');
                    if (!regex.hasMatch(value)) {
                      return 'Space is not allowed here.';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.02.h,
                ),
                CustomText(
                  title: 'Enter age',
                  color: Colors.white,
                  fontFamily: 'Inter',
                  size: 13.sp,
                  weight: FontWeight.w500,
                ),
                SizedBox(
                  height: height * 0.01.h,
                ),
                CustomTextField(
                  controller: _ageController,
                  prefixSvgIconPath: AppSvgs.profile,
                  hintText: 'Enter age',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid age';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.02.h,
                ),
                CustomText(
                  title: 'Select Gender',
                  color: Colors.white,
                  fontFamily: 'Inter',
                  size: 13.sp,
                  weight: FontWeight.w500,
                ),
                SizedBox(
                  height: height * 0.02.h,
                ),
                GenderSelection(
                  onGenderSelected: (gender) {
                    _selectedGender = gender;
                    setState(() {
                      _isGenderValid = true;
                    });
                  },
                ),
                if (!_isGenderValid && _selectedGender == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Please select a gender.',
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ),
                SizedBox(
                  height: height * 0.02.h,
                ),
                CustomText(
                  title: 'Bio',
                  color: Colors.white,
                  fontFamily: 'Inter',
                  size: 13.sp,
                  weight: FontWeight.w500,
                ),
                SizedBox(
                  height: height * 0.01.h,
                ),
                CustomTextField(
                  controller: _bioController,
                  isShowBuildCounter: true,
                  isCommentField: true,
                  maxLength: 150,
                  maxLines: 6,
                  hintText: 'Write here',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a bio';
                    }
                    if (value.length > 150) {
                      return 'Bio cannot exceed 150 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isLoading,
                  builder: (context, value, child) {
                    return CustomButton(
                      loading: value,
                      text: 'Create Profile',
                      textSize: 14,
                      fontWeight: FontWeight.w600,
                      onPressed: () async {
                        isLoading.value = true;
                        setState(() {
                          _isGenderValid = _selectedGender != null;

                          _isImageValid =
                              profileController.pickedImage.value != null;
                        });

                        if (!_isImageValid) {
                          AppUtils.toastMessage(
                              'Please select profile picture');
                        }
                        if (!_formKey.currentState!.validate() ||
                            !_isGenderValid ||
                            !_isImageValid) {
                          isLoading.value = false;
                          return;
                        }

                        try {
                          String? imageUrl;
                          if (profileController.pickedImage.value != null) {
                            print("Uploading image...");
                            imageUrl =
                                await FirestoreServices.uploadProfileImage(
                              profileController.pickedImage.value!,
                            );
                            print("Image uploaded, URL: $imageUrl");
                          }
                          String userID =
                              FirebaseAuth.instance.currentUser!.uid;
                          UserProfile model = UserProfile(
                            age: _ageController.text,
                            bio: _bioController.text,
                            displayname: _displaynameController.text,
                            username: _usernameController.text,
                            gender: _selectedGender!,
                            image: imageUrl,
                            userId: userID,
                          );

                          await FirestoreServices.uploadProfileData(
                            userprofile: model,
                            docId: userID,
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(),
                            ),
                          );
                          _displaynameController.clear();
                          _usernameController.clear();
                          _bioController.clear();
                          _ageController.clear();
                          profileController.clear();
                        } catch (e) {
                          print("Error uploading profile: $e");
                        } finally {
                          isLoading.value = false;
                          print("Loading stopped.");
                        }
                      },
                    );
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
