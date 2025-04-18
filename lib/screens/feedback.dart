import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/screens/edit_profile_setting.dart';
import 'package:drip_tok/screens/help_support.dart';
import 'package:drip_tok/screens/profile_setting.dart';
import 'package:drip_tok/widgets/custom_button.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:drip_tok/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Feedbackk extends StatefulWidget {
  const Feedbackk({super.key});

  @override
  State<Feedbackk> createState() => _FeedbackkState();
}

class _FeedbackkState extends State<Feedbackk> {
  final TextEditingController _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('feedback')
          .doc(currentUserId)
          .set({
        'feedback': _feedbackController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSetting()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(AppSvgs.arrowback),
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.25),
                      CustomText(
                        title: 'Feedback',
                        color: Colors.white,
                        size: 18.sp,
                        fontFamily: 'Poppins',
                        weight: FontWeight.w700,
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.03),
                  CustomText(
                    title: 'Feedback',
                    color: Colors.white,
                    fontFamily: 'Inter',
                    size: 13.sp,
                    weight: FontWeight.w600,
                  ),
                  SizedBox(height: height * 0.02.h),
                  CustomTextField(
                    controller: _feedbackController,
                    isCommentField: true,
                    maxLines: 4,
                    hintText: 'Write here',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Feedback cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: height * 0.5),
                  SizedBox(
                    width: width * 0.9.w,
                    height: height * 0.06.h,
                    child: CustomButton(
                      text: 'Submit',
                      textSize: 14,
                      fontWeight: FontWeight.w600,
                      loading: _isLoading,
                      onPressed: _isLoading ? () {} : _submitFeedback,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
