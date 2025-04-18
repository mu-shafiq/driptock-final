import 'dart:developer';

import 'package:drip_tok/Utils/share_app.dart';
import 'package:drip_tok/bottom_navigation/drips_play_screen.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/controller/admin_controller.dart';
import 'package:drip_tok/controller/my_drips_controllere.dart';
import 'package:drip_tok/controller/reels_controller.dart';
import 'package:drip_tok/controller/user_controller.dart';
import 'package:drip_tok/model/user_profile.dart';
import 'package:drip_tok/model/video_model.dart';
import 'package:drip_tok/screens/follow_list.dart';

import 'package:drip_tok/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
 
import '../controller/user_data_controller.dart';
import '../controller/user_profile_Controller.dart';

class MyWardRobe extends StatefulWidget {
  final String userId;
  const MyWardRobe({super.key, required this.userId});

  @override
  State<MyWardRobe> createState() => _MyWardRobeState();
}

class _MyWardRobeState extends State<MyWardRobe> {
  int selectedIndex = 0;
  late UserProfile? userProfile;
  bool loading = true;

  void _onContainerSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final MyDripsController _controller = Get.find<MyDripsController>();

  @override
  void initState() {
    fetchUserProfile();
    super.initState();
  }

  fetchUserProfile() async {
    try {
      UserProfile? user =
          await Get.find<UserController>().fetchUserById(widget.userId);
      setState(() {
        userProfile = user;
        loading = false;
      });
      log(userProfile!.toMap().toString());
      // if (_controller.userVideos.isEmpty) {
      _controller.fetchUserVideos(widget.userId);
      // }
      // if (_controller.savedDrips.isEmpty) {
      _controller.fetchSavedDrips(widget.userId);
    } catch (e) {
      // TODO
    }
  }


 

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return GetBuilder<UserProfileController>(builder: (userProfileController) {
      return SafeArea(
        child: Scaffold(
          body: loading
              ? Container(
                  color: AppColors.bgdark,
                  child: const Center(child: CircularProgressIndicator()))
              : Stack(
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
                      child: Obx(
                        () {
                          final usermodel =
                              Get.find<UserDataController>().userModel.value;
                          return Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Image.asset(
                                    AppImages.profile,
                                    width: width,
                                    height: height * 0.3,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned.fill(
                                    child: Image.asset(
                                      AppImages.shades,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 30, right: 20, left: 20),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Get.find<UserProfileController>()
                                                .resetProfile();
                                            Get.back();
                                          },
                                          child: Container(
                                            height: height * 0.035,
                                            width: width * 0.08,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.white)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: SvgPicture.asset(
                                                AppSvgs.arrowback,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * 0.24,
                                        ),
                                        // CustomText(
                                        //   title: 'My Profile',
                                        //   color: Colors.white,
                                        //   size: 18.sp,
                                        //   fontFamily: 'Poppins',
                                        //   weight: FontWeight.w600,
                                        // ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: height * 0.32,
                                    left: width * 0.41,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: ClipOval(
                                        child: Image.network(
                                          userProfile!.image ?? '',
                                          height: height * 0.1,
                                          width: height * 0.1,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            AppImages.profile,
                                            height: height * 0.1,
                                            width: height * 0.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: height * 0.12),
                              CustomText(
                                title: (userProfile!.username ?? '') +
                                    (Get.find<AdminController>()
                                            .isThisUserCeo(userProfile!.userId!)
                                        ? ' (CEO)'
                                        : ''),
                                color: Colors.white,
                                size: 14.sp,
                                fontFamily: 'Poppins',
                                weight: FontWeight.w700,
                              ),
                              SizedBox(
                                width: 0.8.sw,
                                child: CustomText(
                                  softWrap: true,
                                  maxLines: 3,
                                  textAlign: TextAlign.center,
                                  title: userProfile!.bio,
                                  color: Colors.white,
                                  size: 13.sp,
                                  fontFamily: 'Poppins',
                                  weight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                              Container(
                                height: height * 0.05,
                                width: width * 0.75,
                                decoration: BoxDecoration(
                                    color: AppColors.textFieledfillColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (userProfile!.followings != null &&
                                              userProfile!
                                                  .followings!.isNotEmpty) {
                                            Get.to(FollowList(
                                                userIds:
                                                    userProfile!.followings!));
                                          }
                                        },
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${Get.find<ReelsController>().formatLikesCount(userProfile!.followings?.length ?? 0)} ',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const TextSpan(
                                                text: 'Following',
                                                style: TextStyle(
                                                  color: AppColors.gray,
                                                  fontSize: 14,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (userProfile!.followers != null &&
                                              userProfile!
                                                  .followers!.isNotEmpty) {
                                            Get.to(FollowList(
                                                userIds:
                                                    userProfile!.followers!));
                                          }
                                        },
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${Get.find<ReelsController>().formatLikesCount(userProfile!.followers?.length ?? 0)} ',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const TextSpan(
                                                text: 'Follower',
                                                style: TextStyle(
                                                  color: AppColors.gray,
                                                  fontSize: 14,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * 0.02,
                              ),
                              Obx(
                                () => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          // Null checks to prevent errors
                                          final currentUserId = FirebaseAuth
                                              .instance.currentUser?.uid;
                                          if (currentUserId != null) {
                                            if (userProfile!.followers
                                                    ?.contains(currentUserId) ??
                                                false) {
                                              userProfile!.followers
                                                  ?.remove(currentUserId);
                                            } else {
                                              userProfile!.followers
                                                  ?.add(currentUserId);
                                            }
                                            userProfileController.follow(
                                                userProfile!.userId ?? '');
                                          }
                                        },
                                        child: Container(
                                          width: width * 0.7,
                                          height: height * 0.059,
                                          decoration: BoxDecoration(
                                            color: userProfileController
                                                        .profileModel
                                                        .value
                                                        .followings
                                                        ?.contains(userProfile!
                                                            .userId) ??
                                                    false
                                                ? AppColors.gray
                                                : AppColors.pink,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                            child: CustomText(
                                              title: (userProfileController
                                                          .profileModel
                                                          .value
                                                          .followings
                                                          ?.contains(
                                                              userProfile!
                                                                  .userId) ??
                                                      false)
                                                  ? 'Following'
                                                  : 'Follow',
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                              size: 14,
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Builder(
                                        builder: (BuildContext innerContext) {
                                          return IconButton(
                                            icon: Image.asset(
                                              AppImages.sharee,
                                              height: height * 0.06,
                                            ),
                                            onPressed: () => shareLink(
                                                'https://driptock.com/${userProfile!.username}',
                                                innerContext),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _onContainerSelected(0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Drips',
                                                style: TextStyle(
                                                  color: selectedIndex == 0
                                                      ? Colors.pink
                                                      : AppColors.gray,
                                                  fontSize: 15,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _onContainerSelected(1),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Wardrobe',
                                                style: TextStyle(
                                                  color: selectedIndex == 1
                                                      ? Colors.pink
                                                      : AppColors.gray,
                                                  fontSize: 15,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 2,
                                          color: AppColors.divider,
                                        ),
                                        AnimatedAlign(
                                          alignment: selectedIndex == 0
                                              ? Alignment.centerLeft
                                              : Alignment.centerRight,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Container(
                                            width: selectedIndex == 0
                                                ? _calculateTextWidth(
                                                    'Drips',
                                                    const TextStyle(
                                                      fontSize: 15,
                                                      fontFamily: "Poppins",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ))
                                                : _calculateTextWidth(
                                                    'Wardrobe',
                                                    const TextStyle(
                                                      fontSize: 15,
                                                      fontFamily: "Poppins",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )),
                                            height: 2,
                                            color: Colors.pink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Center(
                                    child: selectedIndex == 0
                                        ? Obx(() {
                                            if (_controller.isLoading.value) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                backgroundColor: AppColors.pink,
                                              ));
                                            }
                                            if (_controller
                                                .userVideos.isEmpty) {
                                              return Center(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      AppSvgs.home,
                                                      height: Get.height * 0.05,
                                                      color: AppColors.gray,
                                                    ),
                                                    CustomText(
                                                      title: 'Nothing to Show',
                                                      color: Colors.white,
                                                      size: 20.sp,
                                                      fontFamily: 'Poppins',
                                                      weight: FontWeight.w500,
                                                    ),
                                                    CustomText(
                                                      textAlign:
                                                          TextAlign.center,
                                                      title:
                                                          'Drips ${userProfile?.username} posted will appear\nhere.',
                                                      color: AppColors.gray,
                                                      size: 13.sp,
                                                      fontFamily: 'Poppins',
                                                      weight: FontWeight.w500,
                                                    ),
                                                    SizedBox(
                                                      height: Get.height * 0.02,
                                                    ),
                                                    CustomText(
                                                      title: '',
                                                      color: AppColors.pink,
                                                      size: 13.sp,
                                                      fontFamily: 'Poppins',
                                                      weight: FontWeight.w500,
                                                    ),
                                                  ],
                                                ),
                                              ));
                                            }
                                            return GridView.builder(
                                              padding: const EdgeInsets.all(5),
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                mainAxisExtent: 0.09.sh,
                                              ),
                                              itemCount:
                                                  _controller.userVideos.length,
                                              itemBuilder: (context, index) {
                                                final video = _controller
                                                    .userVideos[index];
                                                print(
                                                    '............Length ${video.thumbnail}');
                                                return InkWell(
                                                  onTap: () {
                                                    _controller
                                                        .intializeVideoController(
                                                            video.videoUrl,
                                                            video.videoId);
                                                    print(
                                                        '.................dsffsf${video.videoUrl}');
                                                    List<VideoModel> videos =
                                                        List.from(_controller
                                                            .userVideos);
                                                    videos.sort((a, b) {
                                                      if (a.videoId ==
                                                          video.videoId) {
                                                        return -1; // Move target video up
                                                      }
                                                      if (b.videoId ==
                                                          video.videoId) {
                                                        return 1; // Keep other videos after it
                                                      }
                                                      return 0; // Maintain order for others
                                                    });

                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                      builder: (context) {
                                                        return DripsPlayScreen(
                                                            videoList: videos);
                                                      },
                                                    ));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5,
                                                          vertical: 5),
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.topRight,
                                                        children: [
                                                          Image.network(
                                                            video.thumbnail!,
                                                            fit: BoxFit.cover,
                                                            width: 120,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Container(
                                                                color: Colors
                                                                    .black,
                                                              );
                                                            },
                                                          ),
                                                          video.isPhoto
                                                              ? const SizedBox()
                                                              : Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Image
                                                                      .asset(
                                                                    AppImages
                                                                        .playIcon,
                                                                    scale: 3,
                                                                  ),
                                                                )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          })
                                        : Obx(() {
                                            if (_controller.isLoading.value) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                backgroundColor: AppColors.pink,
                                              ));
                                            }
                                            if (_controller
                                                .savedDrips.isEmpty) {
                                              return Center(
                                                  child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      AppSvgs.home,
                                                      height: Get.height * 0.05,
                                                      color: AppColors.gray,
                                                    ),
                                                    CustomText(
                                                      title: 'Nothing to Show',
                                                      color: Colors.white,
                                                      size: 20.sp,
                                                      fontFamily: 'Poppins',
                                                      weight: FontWeight.w500,
                                                    ),
                                                    CustomText(
                                                      textAlign:
                                                          TextAlign.center,
                                                      title:
                                                          'Drips people posted will appear\nhere.',
                                                      color: AppColors.gray,
                                                      size: 13.sp,
                                                      fontFamily: 'Poppins',
                                                      weight: FontWeight.w500,
                                                    ),
                                                    SizedBox(
                                                      height: Get.height * 0.02,
                                                    ),
                                                    CustomText(
                                                      title: 'Post drip',
                                                      color: AppColors.pink,
                                                      size: 13.sp,
                                                      fontFamily: 'Poppins',
                                                      weight: FontWeight.w500,
                                                    ),
                                                  ],
                                                ),
                                              ));
                                            }
                                            return GridView.builder(
                                              padding: const EdgeInsets.all(5),
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                mainAxisExtent: 0.09.sh,
                                              ),
                                              itemCount:
                                                  _controller.savedDrips.length,
                                              itemBuilder: (context, index) {
                                                final savedDrips = _controller
                                                    .savedDrips[index];
                                                return InkWell(
                                                  onTap: () {
                                                    _controller
                                                        .intializeVideoController(
                                                            savedDrips.videoUrl,
                                                            savedDrips.videoId);
                                                    List<VideoModel> videos =
                                                        List.from(_controller
                                                            .savedDrips);
                                                    videos.sort((a, b) {
                                                      if (a.videoId ==
                                                          savedDrips.videoId) {
                                                        return -1; // Move target video up
                                                      }
                                                      if (b.videoId ==
                                                          savedDrips.videoId) {
                                                        return 1; // Keep other videos after it
                                                      }
                                                      return 0; // Maintain order for others
                                                    });

                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                      builder: (context) {
                                                        return DripsPlayScreen(
                                                            videoList: videos);
                                                      },
                                                    ));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5,
                                                          vertical: 5),
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.topRight,
                                                        children: [
                                                          Image.network(
                                                            savedDrips
                                                                .thumbnail!,
                                                            fit: BoxFit.cover,
                                                            width: 120,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Container(
                                                                color: Colors
                                                                    .black,
                                                              );
                                                            },
                                                          ),
                                                          savedDrips.isPhoto
                                                              ? const SizedBox()
                                                              : Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Image
                                                                      .asset(
                                                                    AppImages
                                                                        .playIcon,
                                                                    scale: 3,
                                                                  ),
                                                                )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          })),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}

double _calculateTextWidth(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return textPainter.size.width;
}
