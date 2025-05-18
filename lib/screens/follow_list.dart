import 'dart:developer';

import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/controller/user_controller.dart';
import 'package:drip_tok/controller/user_profile_Controller.dart';
import 'package:drip_tok/model/user_profile.dart';
import 'package:drip_tok/screens/ward_robe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../constants/app_images.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';

class FollowList extends StatefulWidget {
  final List<String> userIds;
  const FollowList({super.key, required this.userIds});

  @override
  State<FollowList> createState() => _FollowListState();
}

final List<String> imageUrls = [
  AppImages.group1,
  AppImages.group2,
  AppImages.group3,
  AppImages.group4,
  AppImages.group5,
  AppImages.group6,
];
TextEditingController searchController = TextEditingController();

class _FollowListState extends State<FollowList> {
  @override
  void initState() {
    Get.find<UserController>().getfollowList(widget.userIds);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Scaffold(body: GetBuilder<UserController>(builder: (userController) {
      return GetBuilder<UserProfileController>(
          builder: (userProfileController) {
        return Obx(
          () => Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.bglight, AppColors.bgdark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Column(children: [
                Container(
                  height: height * 0.1,
                  decoration:
                      const BoxDecoration(color: AppColors.bottomnavigation),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 40),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: height * 0.04,
                            width: width * 0.08,
                            decoration: BoxDecoration(
                                color: AppColors.bglight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white)),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: SvgPicture.asset(
                                AppSvgs.arrowback,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        CustomText(
                          title: 'Users',
                          color: Colors.white,
                          size: 17.sp,
                          fontFamily: 'Poppins',
                          weight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                ),
                10.verticalSpace,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: const TextStyle(
                      color: Color(0xFFB2B2B2),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.bottomnavigation,
                      hintText: 'Search User',
                      hintStyle: const TextStyle(
                        color: Color(0xFF968E8E),
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(
                            color: Colors.transparent, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(
                            color: Colors.transparent, width: 1),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 30,
                            width: 1,
                            color: const Color(0xFF484848),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Color(0xFFB2B2B2),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          mainAxisExtent: 0.24.sh,
                        ),
                        itemCount: searchController.text.isNotEmpty
                            ? userController.followList
                                .where((user) => user.displayname!
                                    .toLowerCase()
                                    .contains(
                                        searchController.text.toLowerCase()))
                                .length
                            : userController.followList.length,
                        itemBuilder: (context, index) {
                          log(userController.followList
                              .where((user) => user.displayname!
                                  .toLowerCase()
                                  .contains(
                                      searchController.text.toLowerCase()))
                              .toList()
                              .map((e) => e.displayname)
                              .toString());
                          List<UserProfile> users = searchController
                                  .text.isNotEmpty
                              ? userController.followList
                                  .where((user) => user.displayname!
                                      .toLowerCase()
                                      .contains(
                                          searchController.text.toLowerCase()))
                                  .toList()
                              : userController.followList;
                          UserProfile userProfile = users[index];
                          String buttonText;

                          return searchController.text.isNotEmpty &&
                                  !userProfile.displayname!
                                      .toLowerCase()
                                      .contains(
                                          searchController.text.toLowerCase())
                              ? SizedBox()
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MyWardRobe(
                                              userId: userProfile.userId!,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppColors.bottomnavigation,
                                          border: Border.all(
                                              color: const Color(0xFF3C3C3C)),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.sp),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ClipOval(
                                                child: Image.network(
                                                  userProfile.image!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color: Colors.black,
                                                      height: 0.06.sh,
                                                      width: 0.06.sh,
                                                    );
                                                  },
                                                  height: 0.06.sh,
                                                  width: 0.06.sh,
                                                ),
                                              ),
                                              SizedBox(
                                                height: height * 0.01,
                                              ),
                                              CustomText(
                                                title: userProfile.displayname,
                                                color: Colors.white,
                                                size: 15.sp,
                                                fontFamily: 'Poppins',
                                                weight: FontWeight.w700,
                                              ),
                                              CustomText(
                                                title:
                                                    '@${userProfile.username}',
                                                color: const Color(0xFFDADADA),
                                                size: 12.sp,
                                                fontFamily: 'Poppins',
                                                weight: FontWeight.w400,
                                              ),
                                              CustomText(
                                                title:
                                                    '${userProfile.followers?.length} Followers',
                                                color: const Color(0xFFDADADA),
                                                size: 12.sp,
                                                fontFamily: 'Poppins',
                                                weight: FontWeight.w400,
                                              ),
                                              SizedBox(
                                                height: height * 0.007,
                                              ),
                                              !(userProfileController
                                                              .profileModel
                                                              .value
                                                              .followings ??
                                                          [])
                                                      .contains(
                                                          userProfile.userId)
                                                  ? SizedBox(
                                                      width: 0.37.sw,
                                                      child: CustomButton(
                                                        text: 'Follow',
                                                        textSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        onPressed: () async {
                                                          userProfileController
                                                              .follow(
                                                                  userProfile
                                                                      .userId!);
                                                          setState(() {});
                                                        },
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width: 0.37.sw,
                                                      child: CustomButton3(
                                                        text: 'Following',
                                                        textSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        onPressed: () async {
                                                          userProfileController
                                                              .follow(
                                                                  userProfile
                                                                      .userId!);
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      )));
                        }),
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ])),
        );
      });
    }));
  }
}
