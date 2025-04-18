import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Color borderColor;
  final bool isShowBuildCounter;
  final String? prefixSvgIconPath;
  final String? suffixSvgIconPath;
  final VoidCallback? onPrefixIconTap;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final bool isCommentField;
  final bool isLogout;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final String? initialText;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText = '',
    this.onChanged,
    this.borderColor = AppColors.textfieledBorder,
    this.prefixSvgIconPath,
    this.suffixSvgIconPath,
    this.onPrefixIconTap,
    this.onSuffixIconTap,
    this.maxLines = 1,
    this.isCommentField = false,
    this.isLogout = false,
    this.obscureText = false,
    this.validator,
    this.maxLength,
    this.isShowBuildCounter = false,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.initialText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      maxLength: maxLength,
      initialValue: initialText,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      style: const TextStyle(
          color: AppColors.iconsColor,
          fontSize: 14,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w300),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isLogout ? AppColors.orange : AppColors.iconsColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w300,
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: AppColors.textFieledfillColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        prefixIcon: prefixSvgIconPath != null
            ? GestureDetector(
                onTap: onPrefixIconTap,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    prefixSvgIconPath!,
                    color: AppColors.iconsColor,
                    width: 22,
                    height: 22,
                  ),
                ),
              )
            : null,
        suffixIcon: suffixSvgIconPath != null
            ? GestureDetector(
                onTap: onSuffixIconTap,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    suffixSvgIconPath!,
                    color: isLogout ? AppColors.orange : AppColors.iconsColor,
                    width: 18,
                    height: 18,
                  ),
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: isCommentField
              ? BorderRadius.circular(10.0)
              : BorderRadius.circular(60.0),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: isCommentField
              ? BorderRadius.circular(10.0)
              : BorderRadius.circular(60.0),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: isCommentField
              ? BorderRadius.circular(10.0)
              : BorderRadius.circular(30.0),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: isCommentField
              ? BorderRadius.circular(10.0)
              : BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: isCommentField
              ? BorderRadius.circular(10.0)
              : BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      buildCounter: isShowBuildCounter
          ? (BuildContext context,
              {required int currentLength,
              required bool isFocused,
              required int? maxLength}) {
              return Text(
                '$currentLength / $maxLength',
                style: TextStyle(
                  color:
                      currentLength == maxLength ? Colors.white : Colors.white,
                  fontSize: 12.sp,
                ),
              );
            }
          : null,
    );
  }
}
