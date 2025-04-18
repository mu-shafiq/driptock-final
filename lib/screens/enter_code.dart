import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';

class EnterCode extends StatefulWidget {
  const EnterCode({super.key});

  @override
  State<EnterCode> createState() => _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
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
                          border: Border.all(color: Colors.white)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                    title: 'Verification Code',
                    color: Colors.white,
                    size: 17.sp,
                    fontFamily: 'Poppins',
                    weight: FontWeight.w700,
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.06,
              ),
              const Align(
                alignment: Alignment.center,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Please Enter The OTP sent \n to ',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: 'info12345@gmail.com',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              const CustomPinput(),
              SizedBox(
                height: height * 0.05,
              ),
              SizedBox(
                width: width * 0.9.w,
                child: CustomButton(
                  text: 'Submit',
                  textSize: 14,
                  fontWeight: FontWeight.w600,
                  onPressed: () {
                    showPasswordDialog(context);
                  },
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              const Align(
                alignment: Alignment.center,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Did not receive OTP? ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: 'Resend OTP',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.pink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomPinput extends StatefulWidget {
  const CustomPinput({Key? key}) : super(key: key);

  @override
  _CustomPinputState createState() => _CustomPinputState();
}

class _CustomPinputState extends State<CustomPinput> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return _buildPinField(index);
      }),
    );
  }

  Widget _buildPinField(int index) {
    return Container(
      width: 60.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.textFieledfillColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.textfieledBorder,
          width: 1.w,
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            TextField(
              controller: _controllers[index],
              maxLength: 1,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textfieledBorder,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            Text(
              _controllers[index].text.isEmpty ? '0' : '',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.sp,
                fontWeight: FontWeight.w100,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

showPasswordDialog(BuildContext context) {
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
                    title: 'Password Update Successfully',
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
                        Navigator.pop(context);
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
