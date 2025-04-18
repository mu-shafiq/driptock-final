import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String? title;
  final Color? color;
  final int? maxLines;
  final double? size;
  final TextAlign? textAlign;
  final bool softWrap;
  final FontWeight? weight;
  final TextOverflow overflow;
  final String? fontFamily;
  final List<Color>? gradientColors;
  const CustomText({
    super.key,
    this.title,
    this.color,
    this.size,
    this.weight,
    this.textAlign,
    this.softWrap = false,
    this.maxLines,
    this.fontFamily,
    this.overflow = TextOverflow.visible,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    if (gradientColors != null && gradientColors!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: gradientColors!,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        child: Text(
          title ?? '',
          maxLines: maxLines,
          softWrap: softWrap,
          overflow: overflow,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: size,
            fontWeight: weight,
            color: Colors.white,
            fontFamily: fontFamily,
          ),
        ),
      );
    } else {
      return Text(
        title ?? '',
        maxLines: maxLines,
        softWrap: softWrap,
        overflow: maxLines != null && maxLines! < 2
            ? TextOverflow.ellipsis
            : TextOverflow.visible,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: color ?? Colors.black,
          fontFamily: fontFamily,
        ),
      );
    }
  }
}
