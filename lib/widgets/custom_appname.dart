import 'package:drip_tok/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppName extends StatelessWidget {
  final double fontSize;
  final FontWeight fontWeight;

  const AppName({
    super.key,
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Drip',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
          TextSpan(
            text: 'Tock',
            style: TextStyle(
              color: AppColors.pink,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}
