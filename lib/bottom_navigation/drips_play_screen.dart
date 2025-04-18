import 'dart:ui';

import 'package:drip_tok/Utils/share_app.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/controller/reels_controller.dart';
import 'package:drip_tok/model/video_model.dart';
import 'package:drip_tok/screens/comments.dart';
import 'package:drip_tok/widgets/custom_button.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:video_player/video_player.dart';
import '../controller/my_drips_controllere.dart';

class DripsPlayScreen extends StatefulWidget {
  final List<VideoModel> videoList;
  final bool? isMyDrip;
  final bool? isMyWard;

  const DripsPlayScreen(
      {super.key, required this.videoList, this.isMyDrip, this.isMyWard});
  @override
  State<DripsPlayScreen> createState() => _DripsPlayScreenState();
}

class _DripsPlayScreenState extends State<DripsPlayScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    Get.find<MyDripsController>().videoPlayerController?.dispose();
    super.dispose();
  }

  late List<VideoModel> videoList = widget.videoList;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Material(
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              GetBuilder<MyDripsController>(builder: (dripsController) {
                return !dripsController.loading
                    ? videoList.isNotEmpty
                        ? PageView.builder(
                            controller: _pageController,
                            scrollDirection: Axis.vertical,
                            itemCount: videoList.length,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (v) async {
                              await dripsController.videoPlayerController
                                  ?.dispose();
                              dripsController.intializeVideoController(
                                  videoList[v].videoUrl, videoList[v].videoId);
                            },
                            itemBuilder: (context, index) {
                              VideoModel videoModel = videoList[index];

                              return Stack(
                                children: [
                                  SizedBox(
                                    height: size.height,
                                    width: size.width,
                                    child:
                                        !(dripsController.videoPlayerController!
                                                .value.isInitialized)
                                            ? const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 50),
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.pink,
                                                  ),
                                                ),
                                              )
                                            : Stack(
                                                children: [
                                                  VideoPlayer(dripsController
                                                      .videoPlayerController!),
                                                  videoModel.isPhoto
                                                      ? const SizedBox()
                                                      : Positioned(
                                                          bottom:
                                                              size.height * 0,
                                                          child: Container(
                                                            height:
                                                                size.height *
                                                                    0.1,
                                                            width: size.width *
                                                                .98,
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 20),
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  const Color(
                                                                          0xFF666666)
                                                                      .withOpacity(
                                                                          0.15),
                                                                  const Color(
                                                                          0xFF383838)
                                                                      .withOpacity(
                                                                          0.2),
                                                                  const Color(
                                                                          0xFF000000)
                                                                      .withOpacity(
                                                                          0.7)
                                                                ],
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    dripsController
                                                                            .videoPlayerController!
                                                                            .value
                                                                            .isPlaying
                                                                        ? dripsController
                                                                            .videoPlayerController!
                                                                            .pause()
                                                                        : dripsController
                                                                            .videoPlayerController!
                                                                            .play();
                                                                  },
                                                                  child: Icon(
                                                                    dripsController
                                                                            .videoPlayerController!
                                                                            .value
                                                                            .isPlaying
                                                                        ? Icons
                                                                            .pause
                                                                        : Icons
                                                                            .play_arrow,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                5.horizontalSpace,
                                                                SizedBox(
                                                                  width: .7.sw,
                                                                  child:
                                                                      LinearProgressBar(
                                                                    maxSteps: (dripsController.videoPlayerController!.value.duration.compareTo(const Duration(seconds: 1)) <=
                                                                                0
                                                                            ? 10
                                                                            : dripsController.videoPlayerController!.value.duration.inSeconds)
                                                                        .ceil(),
                                                                    progressType:
                                                                        LinearProgressBar
                                                                            .progressTypeLinear,
                                                                    currentStep: dripsController
                                                                        .videoPlayerController!
                                                                        .value
                                                                        .position
                                                                        .inSeconds,
                                                                    progressColor:
                                                                        AppColors
                                                                            .pink,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                ),
                                                                5.horizontalSpace,
                                                                InkWell(
                                                                  onTap: () {
                                                                    dripsController.videoPlayerController!.value.volume <=
                                                                            0
                                                                        ? dripsController
                                                                            .videoPlayerController!
                                                                            .setVolume(
                                                                                1)
                                                                        : dripsController
                                                                            .videoPlayerController!
                                                                            .setVolume(0);
                                                                  },
                                                                  child: Icon(
                                                                    dripsController.videoPlayerController!.value.volume >
                                                                            0
                                                                        ? Icons
                                                                            .volume_up
                                                                        : Icons
                                                                            .volume_mute,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                  ),
                                  // videoModel.user == null
                                  //     ? GetBuilder<UserProfileController>(
                                  //         builder: (userProfileController) {
                                  //         return Padding(
                                  //           padding:
                                  //               const EdgeInsets.only(left: 20),
                                  //           child: Row(
                                  //             crossAxisAlignment:
                                  //                 CrossAxisAlignment.start,
                                  //             children: [
                                  //               SizedBox(
                                  //                 width: MediaQuery.of(context)
                                  //                         .size
                                  //                         .width *
                                  //                     0.12,
                                  //                 child: GestureDetector(
                                  //                     child: userProfileController
                                  //                                     .profileModel
                                  //                                     .value
                                  //                                     .image !=
                                  //                                 null &&
                                  //                             userProfileController
                                  //                                 .profileModel
                                  //                                 .value
                                  //                                 .image!
                                  //                                 .isEmpty
                                  //                         ? Image.asset(
                                  //                             AppImages.profile)
                                  //                         : Container(
                                  //                             height: size.height *
                                  //                                 0.15,
                                  //                             width:
                                  //                                 size.width * 0.1,
                                  //                             decoration:
                                  //                                 BoxDecoration(
                                  //                               shape:
                                  //                                   BoxShape.circle,
                                  //                               image:
                                  //                                   DecorationImage(
                                  //                                 fit: BoxFit.cover,
                                  //                                 image:
                                  //                                     NetworkImage(
                                  //                                   userProfileController
                                  //                                           .profileModel
                                  //                                           .value
                                  //                                           .image ??
                                  //                                       '',
                                  //                                 ),
                                  //                               ),
                                  //                             ),
                                  //                           )),
                                  //               ),
                                  //               Obx(
                                  //                 () => InkWell(
                                  //                   onTap: () {
                                  //                     userProfileController.follow(
                                  //                         videoModel.userId);
                                  //                   },
                                  //                   child: Padding(
                                  //                     padding:
                                  //                         const EdgeInsets.only(
                                  //                             top: 45, left: 8),
                                  //                     child: Column(
                                  //                       crossAxisAlignment:
                                  //                           CrossAxisAlignment
                                  //                               .start,
                                  //                       mainAxisAlignment:
                                  //                           MainAxisAlignment.start,
                                  //                       children: [
                                  //                         CustomText(
                                  //                           title:
                                  //                               userProfileController
                                  //                                       .profileModel
                                  //                                       .value
                                  //                                       .username ??
                                  //                                   '',
                                  //                           color: Colors.white,
                                  //                           size: 13.sp,
                                  //                           fontFamily: 'Poppins',
                                  //                           weight: FontWeight.w500,
                                  //                         ),
                                  //                         CustomText(
                                  //                           // title: userProfileController
                                  //                           //         .profileModel
                                  //                           //         .value
                                  //                           //         .followings!
                                  //                           //         .contains(
                                  //                           //             videoModel
                                  //                           //                 .userId)
                                  //                           //     ? 'Following'
                                  //                           //     : 'Follow',
                                  //                           title: (userProfileController
                                  //                                       .profileModel
                                  //                                       .value
                                  //                                       .userId ==
                                  //                                   videoModel
                                  //                                       .userId)
                                  //                               ? 'You'
                                  //                               : (userProfileController
                                  //                                           .profileModel
                                  //                                           .value
                                  //                                           .followings
                                  //                                           ?.contains(
                                  //                                               videoModel.userId) ??
                                  //                                       false)
                                  //                                   ? 'Following'
                                  //                                   : 'Follow',
                                  //                           color: AppColors.pink,
                                  //                           size: 13.sp,
                                  //                           fontFamily: 'Poppins',
                                  //                           weight: FontWeight.w500,
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               )
                                  //             ],
                                  //           ),
                                  //         );
                                  //       })
                                  //     : Padding(
                                  //         padding: const EdgeInsets.only(left: 20),
                                  //         child: Row(
                                  //           crossAxisAlignment:
                                  //               CrossAxisAlignment.start,
                                  //           children: [
                                  //             SizedBox(
                                  //               width: MediaQuery.of(context)
                                  //                       .size
                                  //                       .width *
                                  //                   0.12,
                                  //               child: GestureDetector(
                                  //                   onTap: () {
                                  //                     Navigator.push(
                                  //                       context,
                                  //                       MaterialPageRoute(
                                  //                         builder: (context) =>
                                  //                             MyWardRobe(
                                  //                           userProfile:
                                  //                               videoModel.user!,
                                  //                         ),
                                  //                       ),
                                  //                     );
                                  //                   },
                                  //                   child: videoModel.user?.image !=
                                  //                               null &&
                                  //                           videoModel.user!.image!
                                  //                               .isEmpty
                                  //                       ? Image.asset(
                                  //                           AppImages.profile)
                                  //                       : Container(
                                  //                           height:
                                  //                               size.height * 0.15,
                                  //                           width: size.width * 0.1,
                                  //                           decoration:
                                  //                               BoxDecoration(
                                  //                             shape:
                                  //                                 BoxShape.circle,
                                  //                             image:
                                  //                                 DecorationImage(
                                  //                               fit: BoxFit.cover,
                                  //                               image: NetworkImage(
                                  //                                 videoModel.user
                                  //                                         ?.image ??
                                  //                                     '',
                                  //                               ),
                                  //                             ),
                                  //                           ),
                                  //                         )),
                                  //             ),
                                  //             GetBuilder<UserProfileController>(
                                  //                 builder: (userProfileController) {
                                  //               return Obx(
                                  //                 () => InkWell(
                                  //                   onTap: () {
                                  //                     userProfileController.follow(
                                  //                         videoModel.userId);
                                  //                   },
                                  //                   child: Padding(
                                  //                     padding:
                                  //                         const EdgeInsets.only(
                                  //                             top: 45, left: 8),
                                  //                     child: Column(
                                  //                       crossAxisAlignment:
                                  //                           CrossAxisAlignment
                                  //                               .start,
                                  //                       mainAxisAlignment:
                                  //                           MainAxisAlignment.start,
                                  //                       children: [
                                  //                         CustomText(
                                  //                           title: videoModel.user
                                  //                                   ?.username ??
                                  //                               '',
                                  //                           color: Colors.white,
                                  //                           size: 13.sp,
                                  //                           fontFamily: 'Poppins',
                                  //                           weight: FontWeight.w500,
                                  //                         ),
                                  //                         CustomText(
                                  //                           // title: userProfileController
                                  //                           //         .profileModel
                                  //                           //         .value
                                  //                           //         .followings!
                                  //                           //         .contains(
                                  //                           //             videoModel
                                  //                           //                 .userId)
                                  //                           //     ? 'Following'
                                  //                           //     : 'Follow',
                                  //                           title: (userProfileController
                                  //                                       .profileModel
                                  //                                       .value
                                  //                                       .userId ==
                                  //                                   videoModel
                                  //                                       .userId)
                                  //                               ? 'You'
                                  //                               : (userProfileController
                                  //                                           .profileModel
                                  //                                           .value
                                  //                                           .followings
                                  //                                           ?.contains(
                                  //                                               videoModel.userId) ??
                                  //                                       false)
                                  //                                   ? 'Following'
                                  //                                   : 'Follow',
                                  //                           color: AppColors.pink,
                                  //                           size: 13.sp,
                                  //                           fontFamily: 'Poppins',
                                  //                           weight: FontWeight.w500,
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               );
                                  //             }),
                                  //           ],
                                  //         ),
                                  //       ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 100, right: 25),
                                      child: Column(
                                        children: [
                                          Builder(
                                            builder:
                                                (BuildContext innerContext) {
                                              return IconButton(
                                                icon: SvgPicture.asset(
                                                  AppSvgs.share,
                                                  height: size.height * 0.05,
                                                ),
                                                onPressed: () => {
                                                  shareLink(videoModel.videoUrl,
                                                      innerContext),
                                                },
                                              );
                                            },
                                          ), 
                                          CustomText(
                                            title: '0',
                                            color: Colors.white,
                                            size: 14.sp,
                                            fontFamily: 'Poppins',
                                            weight: FontWeight.w600,
                                          ),
                                          SizedBox(
                                            height: size.height * 0.02,
                                          ),
                                          InkWell(
                                              onTap: () async {
                                                dripsController.saveVideo(
                                                    videoModel.videoId,
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid);
                                                if (widget.isMyWard == true) {
                                                  videoList.removeWhere(
                                                      (video) =>
                                                          video.videoId ==
                                                          videoModel.videoId);
                                                  if (videoList.isEmpty) {
                                                    Get.back();
                                                  } else {
                                                    await Get.find<
                                                            MyDripsController>()
                                                        .videoPlayerController
                                                        ?.dispose();
                                                    Get.find<
                                                            MyDripsController>()
                                                        .intializeVideoController(
                                                            videoList
                                                                .first.videoUrl,
                                                            videoList
                                                                .first.videoId);
                                                  }

                                                  setState(() {});
                                                }
                                              },
                                              child: !(videoModel.savedBy
                                                          ?.contains(
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid) ??
                                                      false)
                                                  ? SvgPicture.asset(
                                                      AppSvgs.save,
                                                      height:
                                                          size.height * 0.05,
                                                    )
                                                  : CircleAvatar(
                                                      radius:
                                                          size.height * .024,
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                                  255,
                                                                  245,
                                                                  225,
                                                                  225)
                                                              .withOpacity(.3),
                                                      child: const Icon(
                                                        Icons.bookmark,
                                                        color: AppColors.pink,
                                                      ),
                                                    )),
                                          CustomText(
                                            title: dripsController
                                                .formatLikesCount(videoModel
                                                        .savedBy?.length ??
                                                    0),
                                            color: Colors.white,
                                            size: 14.sp,
                                            fontFamily: 'Poppins',
                                            weight: FontWeight.w600,
                                          ),
                                          SizedBox(
                                            height: size.height * 0.02,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Comments(
                                                      videoId:
                                                          videoModel.videoId,
                                                      commentId:
                                                          videoModel.videoId,
                                                    ),
                                                  ));
                                            },
                                            child: SvgPicture.asset(
                                              AppSvgs.comment,
                                              height: size.height * 0.05,
                                            ),
                                          ),
                                          Obx(
                                            () => CustomText(
                                              title: dripsController
                                                  .formatLikesCount(
                                                      dripsController
                                                          .cmntCount.value),
                                              color: Colors.white,
                                              size: 14.sp,
                                              fontFamily: 'Poppins',
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.height * 0.02,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              dripsController.likeVideo(
                                                videoModel.videoId,
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                              );
                                            },
                                            child: !videoModel.likes.contains(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                ? SvgPicture.asset(
                                                    AppSvgs.like,
                                                    height: size.height * 0.05,
                                                  )
                                                : CircleAvatar(
                                                    radius: size.height * .025,
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                                255,
                                                                245,
                                                                225,
                                                                225)
                                                            .withOpacity(.3),
                                                    child: const Icon(
                                                      Icons.thumb_up,
                                                      color: AppColors.pink,
                                                    ),
                                                  ),
                                          ),
                                          CustomText(
                                            title: dripsController
                                                .formatLikesCount(
                                                    videoModel.likes.length),
                                            color: Colors.white,
                                            size: 14.sp,
                                            fontFamily: 'Poppins',
                                            weight: FontWeight.w600,
                                          ),
                                          SizedBox(
                                            height: size.height * 0.02,
                                          ),
                                          widget.isMyDrip == true
                                              ? InkWell(
                                                  onTap: () {
                                                    showDeleteDialog(
                                                        context, index);
                                                  },
                                                  child: CircleAvatar(
                                                    radius: size.height * .025,
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                                255,
                                                                245,
                                                                225,
                                                                225)
                                                            .withOpacity(.3),
                                                    child: const Icon(
                                                      Icons
                                                          .delete_forever_outlined,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            })
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 25),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                        'Drip people posted will appear\nhere.',
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
                          )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 50),
                          child: CircularProgressIndicator(
                            color: Colors.pink,
                          ),
                        ),
                      );
              }),
              Positioned(
                  left: 10,
                  top: 20,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  showDeleteDialog(BuildContext context, int index) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
                      child: const Icon(
                        Icons.delete_forever_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText(
                        title: 'Are you sure you want delete this drip?',
                        fontFamily: 'Poppins',
                        weight: FontWeight.w400,
                        size: 13.sp,
                        color: AppColors.midNight,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: SizedBox(
                            width: 0.4.sw,
                            child: CustomButton1(
                              textColor: AppColors.pink,
                              backgroundColor: AppColors.babypink,
                              borderColor: AppColors.pink,
                              text: 'No',
                              textSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Flexible(
                          child: SizedBox(
                            width: 0.4.sw,
                            child: CustomButton(
                              text: 'Yes',
                              textSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              onPressed: () async {
                                Navigator.pop(context);

                                Get.find<MyDripsController>()
                                    .deleteDrip(videoList[index].videoId);
                                videoList.removeAt(index);
                                if (videoList.isNotEmpty) {
                                  Get.find<MyDripsController>()
                                      .intializeVideoController(
                                          videoList.first.videoUrl,
                                          videoList.first.videoId);
                                } else {
                                  await Get.find<MyDripsController>()
                                      .videoPlayerController
                                      ?.dispose();
                                  Get.back();
                                }
                                setState(() {});
                                Get.find<ReelsController>().fetchAllVideos();
                                Get.find<MyDripsController>()
                                    .fetchUserVideos(videoList[index].userId);
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
