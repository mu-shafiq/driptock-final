import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drip_tok/screens/profile_setting.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/widgets/custom_button.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:drip_tok/widgets/custom_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class HelpSupport extends StatefulWidget {
  const HelpSupport({super.key});

  @override
  State<HelpSupport> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  File? _attachedFile;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();
  Future<void> _pickFile() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _attachedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        String? fileUrl;
        if (_attachedFile != null) {
          final fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final storageRef =
              _storage.ref().child('help_support_files/$fileName');
          final uploadTask = storageRef.putFile(_attachedFile!);
          final snapshot = await uploadTask.whenComplete(() => null);
          fileUrl = await snapshot.ref.getDownloadURL();

          //      fileUrl = await FileUploadingService().uploadImage(_attachedFile!);
        }
        await _firestore.collection('help_support').add({
          'name': _nameController.text,
          'email': _emailController.text,
          'message': _messageController.text,
          'file_url': fileUrl ?? '',
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: AppColors.pink,
              content: Text('Help & Support request submitted successfully!')),
        );
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        setState(() {
          _attachedFile = null;
        });

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ProfileSetting()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
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
                          SizedBox(width: width * 0.2),
                          CustomText(
                            title: 'Help & Support',
                            color: Colors.white,
                            size: 18.sp,
                            fontFamily: 'Poppins',
                            weight: FontWeight.w700,
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.05.h),
                      CustomText(
                        title: 'Your name',
                        color: Colors.white,
                        fontFamily: 'Inter',
                        size: 13.sp,
                        weight: FontWeight.w500,
                      ),
                      SizedBox(height: height * 0.01.h),
                      CustomTextField(
                        controller: _nameController,
                        prefixSvgIconPath: AppSvgs.profile,
                        hintText: 'Your name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
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
                        controller: _emailController,
                        prefixSvgIconPath: AppSvgs.email,
                        hintText: 'Email Address',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: height * 0.02.h),
                      CustomText(
                        title: 'Messages',
                        color: Colors.white,
                        fontFamily: 'Inter',
                        size: 13.sp,
                        weight: FontWeight.w500,
                      ),
                      SizedBox(height: height * 0.01.h),
                      SizedBox(
                        height: height * 0.2.h,
                        child: TextFormField(
                          controller: _messageController,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(
                              color: AppColors.iconsColor,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.bottomnavigation,
                            hintText: 'Write here',
                            hintStyle: const TextStyle(
                              color: AppColors.iconsColor,
                              fontSize: 14,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 1),
                            ),
                            suffixIcon: Padding(
                              padding:
                                  const EdgeInsets.only(right: 20, top: 80),
                              child: GestureDetector(
                                onTap: () {
                                  _pickFile();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.attach_file,
                                      color: AppColors.gray,
                                    ),
                                    CustomText(
                                      title: 'Attach file',
                                      color: AppColors.gray,
                                      fontFamily: 'Inter',
                                      size: 0.03.sw,
                                      weight: FontWeight.w500,
                                    ),
                                    if (_attachedFile != null) ...[
                                      const SizedBox(width: 10),
                                      const Icon(Icons.check_circle,
                                          color: AppColors.pink),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a message';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: height * 0.02.h),
                      SizedBox(height: height * 0.05.h),
                      SizedBox(
                        width: width * 0.9.w,
                        height: height * 0.06.h,
                        child: CustomButton(
                          text: 'Save Changes',
                          textSize: 14,
                          fontWeight: FontWeight.w600,
                          loading: _isLoading,
                          onPressed: _isLoading ? () {} : _saveData,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
