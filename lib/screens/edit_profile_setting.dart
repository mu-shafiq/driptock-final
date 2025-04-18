import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/controller/user_profile_Controller.dart';
import 'package:drip_tok/services/file_uploading_service.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:drip_tok/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_button.dart';

class EditProfileSetting extends StatefulWidget {
  final String displayName;
  final String username;
  final String bio;
  const EditProfileSetting(
      {super.key,
      required this.displayName,
      required this.username,
      required this.bio});
  @override
  State<EditProfileSetting> createState() => _EditProfileSettingState();
}

final userProfile = Get.find<UserProfileController>().profileModelEdit;

class _EditProfileSettingState extends State<EditProfileSetting> {
  bool _isEditing = false;
  File? _imageFile;

  late final TextEditingController _displaynameCotroller =
      TextEditingController(text: widget.displayName);
  late final TextEditingController _usernameCotroller =
      TextEditingController(text: widget.username);
  late final TextEditingController _bioController =
      TextEditingController(text: widget.bio);
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    ValueNotifier<bool> loading = ValueNotifier<bool>(false);
    final ImagePicker _picker = ImagePicker();

    Future<void> _pickImage() async {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          print('Image path: ${_imageFile?.path}');
          print('Image exists: ${_imageFile?.existsSync()}');
        });
      }
    }

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
          padding: const EdgeInsets.only(left: 20, right: 20, top: 60),
          child: SingleChildScrollView(
            child: SizedBox(
                child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              AppSvgs.arrowback,
                            ),
                          ),
                        ),
                      ),
                      CustomText(
                        title: 'Profile Settings',
                        color: Colors.white,
                        size: 18.sp,
                        fontFamily: 'Poppins',
                        weight: FontWeight.w700,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        child: SvgPicture.asset(
                            _isEditing ? AppSvgs.cancel : AppSvgs.editSetting,
                            height: height * 0.02),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipOval(
                          child: _isEditing
                              ? _imageFile == null
                                  ? Image.network(userProfile.image ?? '',
                                      height: height * 0.1,
                                      width: height * 0.1,
                                      fit: BoxFit.cover)
                                  : Image.file(
                                      _imageFile!,
                                      height: height * 0.1,
                                      width: height * 0.1,
                                      fit: BoxFit.cover,
                                    )
                              : Image.network(
                                  userProfile.image ?? '',
                                  height: height * 0.1,
                                  width: height * 0.1,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset('assets/images/profile.png'),
                                ),
                        ),
                        _isEditing
                            ? Positioned(
                                bottom: height * 0.01,
                                right: width * -0.04,
                                child: InkWell(
                                  onTap: _pickImage,
                                  child:
                                      SvgPicture.asset('assets/svgs/edit.svg'),
                                ),
                              )
                            : const SizedBox(),
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
                    controller: _displaynameCotroller,
                    prefixSvgIconPath: AppSvgs.profile,
                    hintText: userProfile.displayname ?? '',
                    enabled: _isEditing,
                    validator: (value) {
                      final trimmedValue = value!.trim();
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
                    title: 'Username',
                    color: Colors.white,
                    fontFamily: 'Inter',
                    size: 13.sp,
                    weight: FontWeight.w500,
                  ),
                  SizedBox(
                    height: height * 0.01.h,
                  ),
                  CustomTextField(
                    controller: _usernameCotroller,
                    prefixSvgIconPath: AppSvgs.profile,
                    hintText: userProfile.username ?? '',
                    enabled: _isEditing,
                    validator: (value) {
                      final regex =
                          RegExp(r'^[a-zA-Z0-9!@#$%^&*()_+=[\]{}|;:,.<>?/-]*$');
                      if (!regex.hasMatch(value!)) {
                        return 'Space is not allowed here.';
                      }
                      return null;
                    },
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
                    maxLength: 80,
                    maxLines: 6,
                    hintText: 'Enter your bio here',
                    enabled: _isEditing,
                    //  onChanged: (value) {},
                  ),
                  SizedBox(
                    height: height * 0.08,
                  ),
                  SizedBox(
                    width: width * 0.9.w,
                    height: height * 0.06.h,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: loading,
                      builder: (context, value, child) {
                        return CustomButton(
                          text: _isEditing ? 'Save Changes' : 'Edit Profile',
                          textSize: 14,
                          loading: value,
                          fontWeight: FontWeight.w600,
                          onPressed: () async {
                            loading.value = true;

                            if (!_formKey.currentState!.validate()) {
                              loading.value = false;
                              return;
                            }

                            if (_isEditing) {
                              String? imageUrl;

                              if (_imageFile != null) {
                                final storageReference =
                                    FirebaseStorage.instance.ref().child(
                                        'profile_images/${DateTime.now().millisecondsSinceEpoch}');
                                final uploadTask =
                                    storageReference.putFile(_imageFile!);
                                final snapshot = await uploadTask;
                                imageUrl = await snapshot.ref.getDownloadURL();
                                // imageUrl = await FileUploadingService()
                                //     .uploadImage(_imageFile!);
                              }

                              final updatedData = {
                                'displayname':
                                    _displaynameCotroller.text.isNotEmpty
                                        ? _displaynameCotroller.text
                                        : userProfile.displayname,
                                'username': _usernameCotroller.text.isNotEmpty
                                    ? _usernameCotroller.text
                                    : userProfile.username,
                                'bio': _bioController.text.isNotEmpty
                                    ? _bioController.text
                                    : userProfile.bio,
                                'image': imageUrl ?? userProfile.image,
                              };

                              final userId =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (userId != null) {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('user_profile')
                                      .doc(userId)
                                      .update(updatedData)
                                      .then((value) {
                                    Get.find<UserProfileController>()
                                        .fetchUserProfile();
                                    setState(() {
                                      _isEditing = false;
                                    });
                                    Get.snackbar(
                                      'Success',
                                      'Profile updated successfully!',
                                      backgroundColor: AppColors.pink,
                                      colorText: Colors.white,
                                    );
                                    loading.value = false;
                                  });
                                } catch (error) {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to update profile: $error',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  loading.value = false;
                                }
                              }
                            } else {
                              setState(() {
                                _isEditing = true;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
