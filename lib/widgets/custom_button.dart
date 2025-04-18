import 'package:drip_tok/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double paddingHorizontal;
  final double paddingVertical;
  final double textSize;
  final FontWeight fontWeight;
  final bool loading;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.pink,
    this.textColor = Colors.white,
    this.borderRadius = 30.0,
    this.loading = false,
    this.paddingHorizontal = 20.0,
    this.paddingVertical = 12.0,
    this.textSize = 16.0,
    this.fontWeight = FontWeight.w600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: backgroundColor,
      textColor: textColor,
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: loading
          ? const Center(
              child: CupertinoActivityIndicator(
              color: Colors.white,
            ))
          : Center(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: textSize,
                  fontWeight: fontWeight,
                ),
              ),
            ),
    );
  }
}

class CustomButton1 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderRadius;
  final double paddingHorizontal;
  final double paddingVertical;
  final double textSize;
  final FontWeight fontWeight;
  final bool loading;

  const CustomButton1({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderColor = Colors.pink,
    this.backgroundColor = AppColors.babypink,
    this.textColor = Colors.white,
    this.borderRadius = 30.0,
    this.loading = false,
    this.paddingHorizontal = 20.0,
    this.paddingVertical = 12.0,
    this.textSize = 16.0,
    this.fontWeight = FontWeight.w600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        color: backgroundColor,
        textColor: textColor,
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: loading
            ? const CupertinoActivityIndicator()
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Poppins',
                  fontSize: textSize,
                  fontWeight: fontWeight,
                ),
              ),
      ),
    );
  }
}

class CustomButton2 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderRadius;
  final double paddingHorizontal;
  final double paddingVertical;
  final double textSize;
  final FontWeight fontWeight;
  final bool loading;

  const CustomButton2({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderColor = Colors.pink,
    this.backgroundColor = const Color(0xFF6B6C77),
    this.textColor = Colors.white,
    this.borderRadius = 30.0,
    this.loading = false,
    this.paddingHorizontal = 20.0,
    this.paddingVertical = 12.0,
    this.textSize = 16.0,
    this.fontWeight = FontWeight.w600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        color: backgroundColor,
        textColor: textColor,
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: loading
            ? const CupertinoActivityIndicator()
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Poppins',
                  fontSize: textSize,
                  fontWeight: fontWeight,
                ),
              ),
      ),
    );
  }
}

class CustomButton3 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderRadius;
  final double paddingHorizontal;
  final double paddingVertical;
  final double textSize;
  final FontWeight fontWeight;
  final bool loading;

  const CustomButton3({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderColor = AppColors.borderSide,
    this.backgroundColor = AppColors.bgdark,
    this.textColor = Colors.white,
    this.borderRadius = 30.0,
    this.loading = false,
    this.paddingHorizontal = 20.0,
    this.paddingVertical = 12.0,
    this.textSize = 16.0,
    this.fontWeight = FontWeight.w600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        color: backgroundColor,
        textColor: textColor,
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: loading
            ? const CupertinoActivityIndicator()
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Poppins',
                  fontSize: textSize,
                  fontWeight: fontWeight,
                ),
              ),
      ),
    );
  }
}
