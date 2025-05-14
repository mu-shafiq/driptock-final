import 'dart:developer';
import 'dart:ui';
import 'package:drip_tok/Utils/share_app.dart';
import 'package:drip_tok/bottom_navigation/report_sheet.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/controller/admin_controller.dart';
import 'package:drip_tok/controller/reels_controller.dart';
import 'package:drip_tok/controller/user_profile_Controller.dart';
import 'package:drip_tok/model/video_model.dart';
import 'package:drip_tok/screens/comments.dart';
import 'package:drip_tok/screens/ward_robe.dart';
import 'package:drip_tok/widgets/custom_button.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  late final ReelsController reelsController;

  @override
  void initState() {
    super.initState();
    reelsController = Get.put(ReelsController());
    final adminController = Get.put(AdminController());
    // Future.delayed(const Duration(seconds: 1), () {
    //   reelsController.videoControllerList.isNotEmpty
    //       ? reelsController.videoControllerList[0].play()
    //       : null;
    // });
    // Future.delayed(Duration.zero, () {
    //   if (reelsController.videoList.isEmpty) {
    //     reelsController.fetchAllVideos();
    //   }
    // });
    //  reelsController.videoList.isEmpty ? reelsController.fetchAllVideos() : null;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: GetBuilder<ReelsController>(builder: (reelsController) {
            return !reelsController.loading
                ? reelsController.videoList.isNotEmpty
                    ? PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        itemCount: reelsController.videoList.length,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (v) async {
                          if (reelsController.videoControllerIndex < v) {
                            reelsController.handleControllersOnPageForward(v);

                            await reelsController.videoControllerList[v - 1]
                                ?.pause();
                            reelsController.update();
                            reelsController.fetchCommentCount(
                                reelsController.videoList[v].videoId);
                            setState(() {});
                            await reelsController.videoControllerList[v]
                                ?.play();
                          } else {
                            reelsController.handleControllersOnPageBackward(v);
                            await reelsController.videoControllerList[v + 1]
                                ?.pause();
                            reelsController.update();
                            reelsController.fetchCommentCount(
                                reelsController.videoList[v].videoId);
                            setState(() {});
                            await reelsController.videoControllerList[v]
                                ?.play();
                          }
                          reelsController.setVideoControllerIndex(v);
                        },
                        itemBuilder: (context, index) {
                          VideoModel videoModel =
                              reelsController.videoControllerIndex < index ||
                                      reelsController.videoControllerIndex ==
                                          0 ||
                                      reelsController.videoControllerIndex <
                                          reelsController.videoList.length
                                  ? reelsController.videoList[index]
                                  : reelsController.videoList[index + 1];
                          print(
                              '.........the data of user is ${videoModel.userId}');

                          return Stack(
                            children: [
                              GestureDetector(
                                onLongPress: () {
                                  if (Get.find<AdminController>().isAdmin) {
                                    showDeleteDialogue(videoModel.videoId);
                                  }
                                },
                                child: SizedBox(
                                  height: size.height,
                                  width: size.width,
                                  child: reelsController.videoControllerList
                                                      .length -
                                                  1 <
                                              index ||
                                          reelsController
                                                  .videoControllerList[index] ==
                                              null
                                      ? InkWell(
                                          onTap: () {
                                            reelsController.fetchAllVideos();
                                          },
                                          child: Container(
                                            color: Colors.black,
                                            child: const Icon(
                                              Icons.replay,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : Stack(
                                          children: [
                                            VideoPlayer(reelsController
                                                .videoControllerList[index]!),
                                            // Center(
                                            //   child: AspectRatio(
                                            //     aspectRatio: reelsController
                                            //         .videoControllerList[index]!
                                            //         .value
                                            //         .aspectRatio,
                                            //     child: VideoPlayer(
                                            //         reelsController
                                            //                 .videoControllerList[
                                            //             index]!),
                                            //   ),
                                            // ),
                                            Positioned.fill(
                                                child: GestureDetector(
                                              onTap: () {
                                                var videoController =
                                                    reelsController
                                                            .videoControllerList[
                                                        index];
                                                if (videoController!
                                                    .value.isPlaying) {
                                                  videoController.pause();
                                                } else {
                                                  videoController.play();
                                                }
                                              },
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  if (!reelsController
                                                      .videoControllerList[
                                                          index]!
                                                      .value
                                                      .isInitialized)
                                                    const CircularProgressIndicator(
                                                      color: Colors.pink,
                                                    ),
                                                  if (reelsController
                                                          .videoControllerList[
                                                              index]!
                                                          .value
                                                          .isInitialized &&
                                                      !reelsController
                                                          .videoControllerList[
                                                              index]!
                                                          .value
                                                          .isPlaying)
                                                    const Icon(
                                                      Icons
                                                          .play_circle_outline_outlined,
                                                      color: AppColors.pink,
                                                      size: 60.0,
                                                    ),
                                                ],
                                              ),
                                            )),
                                            videoModel.isPhoto
                                                ? const SizedBox()
                                                : Positioned(
                                                    bottom: size.height * 0,
                                                    child: Container(
                                                      height: size.height * 0.2,
                                                      width: size.width * .98,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 70),
                                                      decoration: BoxDecoration(
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
                                                                    0.7),
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
                                                              var videoController =
                                                                  reelsController
                                                                          .videoControllerList[
                                                                      index];
                                                              videoController!
                                                                      .value
                                                                      .isPlaying
                                                                  ? videoController
                                                                      .pause()
                                                                  : videoController
                                                                      .play();
                                                            },
                                                            child: Icon(
                                                              reelsController
                                                                      .videoControllerList[
                                                                          index]!
                                                                      .value
                                                                      .isPlaying
                                                                  ? Icons.pause
                                                                  : Icons
                                                                      .play_arrow,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          SizedBox(
                                                            width: size.width *
                                                                0.7,
                                                            child:
                                                                LinearProgressBar(
                                                              maxSteps: (reelsController.videoControllerList[index]!.value.duration.compareTo(const Duration(
                                                                              seconds:
                                                                                  1)) <=
                                                                          0
                                                                      ? 10
                                                                      : reelsController
                                                                          .videoControllerList[
                                                                              index]!
                                                                          .value
                                                                          .duration
                                                                          .inSeconds)
                                                                  .ceil(),
                                                              progressType:
                                                                  LinearProgressBar
                                                                      .progressTypeLinear,
                                                              currentStep:
                                                                  reelsController
                                                                      .videoControllerList[
                                                                          index]!
                                                                      .value
                                                                      .position
                                                                      .inSeconds,
                                                              progressColor:
                                                                  AppColors
                                                                      .pink,
                                                              backgroundColor:
                                                                  Colors.grey,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          InkWell(
                                                            onTap: () {
                                                              var videoController =
                                                                  reelsController
                                                                          .videoControllerList[
                                                                      index];
                                                              videoController!
                                                                          .value
                                                                          .volume <=
                                                                      0
                                                                  ? videoController
                                                                      .setVolume(
                                                                          1)
                                                                  : videoController
                                                                      .setVolume(
                                                                          0);
                                                            },
                                                            child: Icon(
                                                              reelsController
                                                                          .videoControllerList[
                                                                              index]!
                                                                          .value
                                                                          .volume >
                                                                      0
                                                                  ? Icons
                                                                      .volume_up
                                                                  : Icons
                                                                      .volume_mute,
                                                              color:
                                                                  Colors.white,
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
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      child: GestureDetector(
                                          onTap: () async {
                                            await reelsController
                                                .videoControllerList[index]!
                                                .pause();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MyWardRobe(
                                                  userId: videoModel.userId,
                                                ),
                                              ),
                                            );
                                          },
                                          child: videoModel.userImage.isEmpty
                                              ? Container(
                                                  height: size.height * 0.1,
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    child: Image.asset(
                                                      AppImages.profile,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          const SizedBox(),
                                                      fit: BoxFit.fitWidth,
                                                      // height: size.height * 0.7,
                                                      width: size.width * .1,
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  height: size.height * 0.1,
                                                  // width: size.width * 0.1,
                                                  // decoration:
                                                  //     const BoxDecoration(
                                                  //   shape: BoxShape.circle,
                                                  // ),
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage:
                                                        Image.network(
                                                      videoModel.userImage,
                                                      errorBuilder: (context,
                                                              url, error) =>
                                                          Image.asset(AppImages
                                                              .profile),
                                                      fit: BoxFit.fitWidth,
                                                      width: size.width * .1,
                                                    ).image,
                                                  ),
                                                )),
                                    ),
                                    GetBuilder<UserProfileController>(
                                      builder: (userProfileController) {
                                        return Obx(
                                          () => InkWell(
                                            onTap: () {
                                              userProfileController
                                                  .follow(videoModel.userId);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20, left: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    title: Get.find<
                                                                AdminController>()
                                                            .isThisUserCeo(
                                                                videoModel
                                                                    .userId)
                                                        ? "Nina DripTock CEO @Nina"
                                                        : videoModel.userName,
                                                    color: Colors.white,
                                                    size: 13.sp,
                                                    fontFamily: 'Poppins',
                                                    weight: FontWeight.w500,
                                                  ),
                                                  CustomText(
                                                    title: (userProfileController
                                                                .profileModel
                                                                .value
                                                                .userId ==
                                                            videoModel.userId)
                                                        ? 'You'
                                                        : (userProfileController
                                                                    .profileModel
                                                                    .value
                                                                    .followings
                                                                    ?.contains(
                                                                        videoModel
                                                                            .userId) ??
                                                                false)
                                                            ? 'Following'
                                                            : 'Follow',
                                                    color: AppColors.pink,
                                                    size: 13.sp,
                                                    fontFamily: 'Poppins',
                                                    weight: FontWeight.w500,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 80, right: 25),
                                  child: Column(
                                    children: [
                                      Builder(
                                        builder: (BuildContext innerContext) {
                                          return IconButton(
                                            icon: SvgPicture.asset(
                                              AppSvgs.share,
                                              height: size.height * 0.05,
                                            ),
                                            onPressed: () => shareLink(
                                                videoModel.videoUrl,
                                                innerContext),
                                          );
                                        },
                                      ),
                                      // CustomText(
                                      //   title: '',
                                      //   color: Colors.white,
                                      //   size: 14.sp,
                                      //   fontFamily: 'Poppins',
                                      //   weight: FontWeight.w600,
                                      // ),
                                      SizedBox(
                                        height: size.height * 0.02,
                                      ),
                                      InkWell(
                                          onTap: () {
                                            reelsController.saveVideo(
                                                videoModel.videoId,
                                                FirebaseAuth
                                                    .instance.currentUser!.uid);
                                          },
                                          child: !(videoModel.savedBy?.contains(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid) ??
                                                  false)
                                              ? SvgPicture.asset(
                                                  AppSvgs.save,
                                                  height: size.height * 0.05,
                                                )
                                              : CircleAvatar(
                                                  radius: size.height * .024,
                                                  backgroundColor:
                                                      const Color.fromARGB(255,
                                                              245, 225, 225)
                                                          .withOpacity(.3),
                                                  child: const Icon(
                                                    Icons.bookmark,
                                                    color: AppColors.pink,
                                                  ),
                                                )),
                                      CustomText(
                                        title: reelsController.formatLikesCount(
                                            videoModel.savedBy?.length ?? 0),
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
                                                builder: (context) => Comments(
                                                  videoId: videoModel.videoId,
                                                  commentId: videoModel.videoId,
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
                                          title: reelsController
                                              .formatLikesCount(reelsController
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
                                          reelsController.likeVideo(
                                            videoModel.videoId,
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                          );
                                        },
                                        child: !videoModel.likes.contains(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid)
                                            ? SvgPicture.asset(
                                                AppSvgs.like,
                                                height: size.height * 0.05,
                                              )
                                            : CircleAvatar(
                                                radius: size.height * .025,
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                            255, 245, 225, 225)
                                                        .withOpacity(.3),
                                                child: const Icon(
                                                  Icons.thumb_up,
                                                  color: AppColors.pink,
                                                ),
                                              ),
                                      ),
                                      CustomText(
                                        title: reelsController.formatLikesCount(
                                            videoModel.likes.length),
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
                                          showBlockDialogue(videoModel.userId);
                                        },
                                        child: CircleAvatar(
                                          radius: size.height * .025,
                                          backgroundColor: const Color.fromARGB(
                                                  255, 245, 225, 225)
                                              .withOpacity(.3),
                                          child: const Icon(
                                            Icons.block,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      CustomText(
                                        title: 'Block User',
                                        color: Colors.white,
                                        size: 8.sp,
                                        fontFamily: 'Poppins',
                                        weight: FontWeight.w600,
                                      ), // तीन डॉट्स आइकन
                                      SizedBox(
                                        height: size.height * 0.02,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(20)),
                                            ),
                                            builder: (context) {
                                              return ReportBottomSheet(
                                                  videoId: videoModel.videoId);
                                            },
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: size.height * .025,
                                          backgroundColor: const Color.fromARGB(
                                                  255, 245, 225, 225)
                                              .withOpacity(.3),
                                          child: const Icon(
                                            Icons.report,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      CustomText(
                                        title: 'Report',
                                        color: Colors.white,
                                        size: 8.sp,
                                        fontFamily: 'Poppins',
                                        weight: FontWeight.w600,
                                      ), // तीन
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
                              title: 'Drip people posted will appear\nhere.',
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
                      ))
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: CircularProgressIndicator(
                        color: Colors.pink,
                      ),
                    ),
                  );
          }),
        ),
      ),
    );
  }

  showDeleteDialogue(String id) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    showDialog(
      context: context,
      barrierDismissible: false,
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
                      child: Image.asset(AppImages.logout),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText(
                        title: 'Are you sure you want to delete this video?',
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
                              onPressed: () {
                                Navigator.pop(context);

                                reelsController.deleteVideo(id);
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

  showBlockDialogue(String id) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    showDialog(
      context: context,
      barrierDismissible: false,
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
                    left: 10, top: 20, bottom: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 130.h,
                      width: 130.w,
                      child: const Icon(
                        Icons.block,
                        size: 140,
                        color: AppColors.pink,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    CustomText(
                      title:
                          'Are you sure you want to block\n content from this user?',
                      fontFamily: 'Poppins',
                      weight: FontWeight.w400,
                      textAlign: TextAlign.center,
                      size: 15.sp,
                      color: AppColors.midNight,
                    ),
                    SizedBox(
                      height: height * 0.04,
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
                              onPressed: () {
                                Navigator.pop(context);

                                reelsController.restrictVideo(id);
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

void showBottomAlertDialog(BuildContext context, String url) {
  var size = MediaQuery.of(context).size;
  double width = size.width;
  double height = size.height;

  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.215,
              decoration: const BoxDecoration(
                color: AppColors.bgdark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                  color: AppColors.bglight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                  AppSvgs.arrowback,
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: const EdgeInsets.only(left: 120),
                            child: const Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    const Divider(
                      thickness: 1,
                      color: AppColors.divider,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(text: url));
                          },
                          child: Image.asset(
                            AppImages.link,
                            height: height * 0.03,
                          ),
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        SizedBox(
                          width: .5.sw,
                          child: Text(
                            url,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.wattsup,
                          height: height * 0.04,
                        ),
                        SizedBox(width: width * 0.03),
                        Image.asset(AppImages.facebook, height: height * 0.04),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        Image.asset(AppImages.insta, height: height * 0.04),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        Image.asset(AppImages.messenger, height: height * 0.04),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
