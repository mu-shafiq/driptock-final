import 'package:flutter/material.dart';

class GradientDivider extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final double height;
  final double dividerHeight;
  final Color leftColor;
  final Color rightColor;
  final double dividerWidth;

  const GradientDivider({
    Key? key,
    this.text = 'Or',
    this.textStyle,
    this.height = 40.0,
    this.dividerHeight = 2.0,
    required this.leftColor,
    required this.rightColor,
    this.dividerWidth = 90.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: dividerWidth,
            height: dividerHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [leftColor, Colors.white],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              text,
              style: textStyle ??
                  const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
            ),
          ),
          Container(
            width: dividerWidth,
            height: dividerHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.white, rightColor],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
