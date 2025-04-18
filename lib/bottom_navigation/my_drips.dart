import 'package:drip_tok/bottom_navigation/drips_play_screen.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/model/video_model.dart';
import 'package:drip_tok/screens/follow_list.dart';
import 'package:drip_tok/screens/profile_setting.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controller/my_drips_controllere.dart';
import '../controller/reels_controller.dart';
import '../controller/user_profile_Controller.dart';

class MyDrips extends StatefulWidget {
  const MyDrips({super.key});
  @override
  State<MyDrips> createState() => _MyDripsState();
}

class _MyDripsState extends State<MyDrips> {
  int selectedIndex = 0;

  void _onContainerSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final MyDripsController _controller = Get.find<MyDripsController>();

  @override
  void dispose() {
    _controller.videoPlayerController?.dispose();
    super.dispose();
  }

  late final ReelsController reelsController;
  @override
  void initState() {
    _controller.fetchUserVideos(FirebaseAuth.instance.currentUser!.uid);

    _controller.fetchSavedDrips(FirebaseAuth.instance.currentUser!.uid);

    reelsController = Get.put(ReelsController());
    Future.delayed(const Duration(microseconds: 1), () {
      reelsController.videoControllerList.isNotEmpty
          ? reelsController.videoControllerList[0]?.pause()
          : null;
    });
    Get.find<UserProfileController>().fetchUserProfile();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return Future.value(true);
        },
        child: Scaffold(
          body: Stack(
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
                    final userProfile =
                        Get.find<UserProfileController>().profileModel.value;
                    print('.......................email${userProfile.toMap()}');
                    return Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              AppImages.profile,
                              width: width,
                              height: height * 0.25,
                              fit: BoxFit.fill,
                            ),
                            Positioned.fill(
                              child: Image.asset(
                                AppImages.shades,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30, right: 20, left: 150),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ProfileSetting(),
                                            ));
                                      },
                                      child: SvgPicture.asset(
                                          AppSvgs.share_profile))
                                ],
                              ),
                            ),
                            Positioned(
                              top: height * 0.26,
                              left: width * 0.38,
                              child: ClipOval(
                                child: Image.network(
                                  userProfile.image ?? '',
                                  height: height * 0.1,
                                  width: height * 0.1,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    AppImages.profile,
                                    height: height * 0.1,
                                    width: height * 0.1,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: height * 0.12,
                        ),
                        CustomText(
                          title: userProfile.displayname ?? '',
                          color: Colors.white,
                          size: 14.sp,
                          fontFamily: 'Poppins',
                          weight: FontWeight.w700,
                        ),
                        CustomText(
                          title: userProfile.username ?? '',
                          color: Colors.white,
                          size: 11.sp,
                          fontFamily: 'Poppins',
                          weight: FontWeight.w400,
                        ),
                        userProfile.bio != null && userProfile.bio!.isNotEmpty
                            ? SizedBox(
                                width: 0.8.sw,
                                child: CustomText(
                                  softWrap: true,
                                  maxLines: 3,
                                  textAlign: TextAlign.center,
                                  title: userProfile.bio ?? '',
                                  color: Colors.white,
                                  size: 13.sp,
                                  fontFamily: 'Poppins',
                                  weight: FontWeight.w400,
                                ),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Container(
                          height: height * 0.05,
                          width: width * 0.75,
                          decoration: BoxDecoration(
                              color: AppColors.textFieledfillColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (userProfile.followers != null &&
                                          userProfile.followers!.isNotEmpty) {
                                        Get.to(FollowList(
                                            userIds: userProfile.followers!));
                                      }
                                    },
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '${userProfile.followers?.length ?? 0} ',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: 'Followers',
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
                                      if (userProfile.followings != null &&
                                          userProfile.followings!.isNotEmpty) {
                                        Get.to(FollowList(
                                            userIds: userProfile.followings!));
                                      }
                                    },
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '${userProfile.followings?.length ?? 0} ',
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
                                ]),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _onContainerSelected(0),
                              child: Container(
                                width: width * 0.42,
                                height: height * 0.059,
                                decoration: BoxDecoration(
                                  color: selectedIndex == 0
                                      ? AppColors.pink
                                      : AppColors.textFieledfillColor,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: selectedIndex == 0
                                        ? AppColors.pink
                                        : AppColors.textfieledBorder,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'My Drips',
                                    style: TextStyle(
                                      color: selectedIndex == 0
                                          ? Colors.white
                                          : AppColors.gray,
                                      fontSize: 14,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () => _onContainerSelected(1),
                              child: Container(
                                width: width * 0.42,
                                height: height * 0.059,
                                decoration: BoxDecoration(
                                  color: selectedIndex == 1
                                      ? AppColors.pink
                                      : AppColors.textFieledfillColor,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: selectedIndex == 1
                                        ? AppColors.pink
                                        : AppColors.textfieledBorder,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Wardrobe',
                                    style: TextStyle(
                                      color: selectedIndex == 1
                                          ? Colors.white
                                          : AppColors.gray,
                                      fontSize: 14,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        const Divider(
                          thickness: 1,
                          color: AppColors.divider,
                          endIndent: 10,
                          indent: 10,
                        ),
                        Expanded(
                          child: Center(
                              child: selectedIndex == 0
                                  ? Obx(() {
                                      if (_controller.isLoading.value) {
                                        return const Center(
                                            child: CircularProgressIndicator(
                                          backgroundColor: AppColors.pink,
                                        ));
                                      }
                                      if (_controller.userVideos.isEmpty) {
                                        return Center(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0),
                                          child: SingleChildScrollView(
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
                                                  textAlign: TextAlign.center,
                                                  title:
                                                      'Drips You posted will appear\nhere.',
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
                                          final video =
                                              _controller.userVideos[index];
                                          print(
                                              '............Length${video.videoUrl}');
                                          return InkWell(
                                            onTap: () {
                                              print(
                                                  '.................dsffsf${video.videoUrl}');
                                              _controller
                                                  .intializeVideoController(
                                                      video.videoUrl,
                                                      video.videoId);
                                              print(
                                                  '.................dsffsf${video.videoUrl}');
                                              List<VideoModel> videos =
                                                  List.from(
                                                      _controller.userVideos);
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
                                                    videoList: videos,
                                                    isMyDrip: true,
                                                  );
                                                },
                                              ));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                child: Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    Image.network(
                                                      video.thumbnail!,
                                                      fit: BoxFit.cover,
                                                      width: 120,
                                                      // height: 10,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          color: Colors.black,
                                                        );
                                                      },
                                                    ),
                                                    video.isPhoto
                                                        ? const SizedBox()
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Image.asset(
                                                              AppImages
                                                                  .playIcon,
                                                              scale: 3,
                                                            ),
                                                          )
                                                    // const Icon(
                                                    //   Icons.play_arrow,
                                                    //   color: Colors.white,
                                                    //   size: 20,
                                                    // )
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
                                            child: CircularProgressIndicator(
                                          backgroundColor: AppColors.pink,
                                        ));
                                      }
                                      if (_controller.savedDrips.isEmpty) {
                                        return Center(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                AppSvgs.wardrobe,
                                                height: Get.height * 0.05,
                                                color: AppColors.gray,
                                              ),
                                              CustomText(
                                                title: 'Wardrobe is Empty',
                                                color: Colors.white,
                                                size: 20.sp,
                                                fontFamily: 'Poppins',
                                                weight: FontWeight.w500,
                                              ),
                                              CustomText(
                                                textAlign: TextAlign.center,
                                                title:
                                                    'you are yet to save any drips',
                                                color: AppColors.gray,
                                                size: 13.sp,
                                                fontFamily: 'Poppins',
                                                weight: FontWeight.w500,
                                              ),
                                              SizedBox(
                                                height: Get.height * 0.02,
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
                                          final savedDrips =
                                              _controller.savedDrips[index];

                                          return InkWell(
                                            onTap: () {
                                              _controller
                                                  .intializeVideoController(
                                                      savedDrips.videoUrl,
                                                      savedDrips.videoId);
                                              print(
                                                  '.................dsffsf${savedDrips.videoUrl}');
                                              List<VideoModel> videos =
                                                  List.from(
                                                      _controller.savedDrips);
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
                                                      isMyWard: true,
                                                      videoList: videos);
                                                },
                                              ));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                child: Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    Image.network(
                                                      savedDrips.thumbnail!,
                                                      fit: BoxFit.cover,
                                                      width: 120,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          color: Colors.black,
                                                        );
                                                      },
                                                    ),
                                                    savedDrips.isPhoto
                                                        ? const SizedBox()
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Image.asset(
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
                        SizedBox(height: height * 0.12),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
