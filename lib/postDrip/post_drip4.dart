import 'package:drip_tok/postDrip/post_drip5.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/app_images.dart';

class PostDrip4 extends StatefulWidget {
  const PostDrip4({super.key});

  @override
  State<PostDrip4> createState() => _PostDrip4State();
}

class _PostDrip4State extends State<PostDrip4> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.postDrip),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 60),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: height * 0.035,
                        width: width * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            AppSvgs.arrowback,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.05),
                    CustomText(
                      title: 'Post drip',
                      color: Colors.white,
                      size: 18.sp,
                      fontFamily: 'Poppins',
                      weight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.asset(
                      AppImages.dripShade,
                      width: width,
                      fit: BoxFit.contain,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 40.0, left: 10, right: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PostDrip5(),
                              ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: SizedBox(
                                  child: Image.asset(
                                AppImages.recordd,
                                height: height * 0.06,
                              )),
                            ),
                            SizedBox(
                              width: 0.04.sw,
                            ),
                            SizedBox(
                                height: height * 0.04,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      AppImages.playprogess,
                                    ),
                                    Positioned(
                                        left: size.width * 0.075,
                                        child:
                                            SvgPicture.asset(AppSvgs.record)),
                                    Positioned(
                                        right: size.width * 0.12,
                                        child: SvgPicture.asset(AppSvgs.record))
                                  ],
                                )),
                            SizedBox(
                              width: 0.04.sw,
                            ),
                            Flexible(
                              child: SizedBox(
                                  child: Image.asset(
                                AppImages.send,
                                height: height * 0.07,
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
