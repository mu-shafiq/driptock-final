import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/controller/reels_controller.dart';
import 'package:drip_tok/model/comment_model.dart';
import 'package:drip_tok/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../widgets/custom_text.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String videoId;
  final String commentId;
  const Comments({
    super.key,
    required this.videoId,
    required this.commentId,
  });

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final TextEditingController _cmnController = TextEditingController();

  final reelsController = Get.find<ReelsController>();
  ScrollController scrollController = ScrollController();
  bool loading = true;
  @override
  void initState() {
    super.initState();

    reelsController.videoControllerList[0]?.pause();

    Future.delayed(const Duration(seconds: 2)).then((onValue) {
      Get.find<ReelsController>().fetchVideoComment(widget.videoId);
    });

    Future.delayed(const Duration(microseconds: 1), () {
      reelsController.videoControllerList.isNotEmpty
          ? reelsController
              .videoControllerList[reelsController.videoControllerIndex]
              ?.pause()
          : null;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return GetBuilder<ReelsController>(builder: (reelsController) {
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Stack(
          alignment: Alignment.centerRight,
          children: [
            CustomTextField(
              prefixSvgIconPath: AppSvgs.comment,
              hintText: 'Enter your comment here..',
              controller: _cmnController,
            ),
            InkWell(
              onTap: () {
                if (_cmnController.text.isNotEmpty) {
                  reelsController.addComment(
                      widget.videoId,
                      FirebaseAuth.instance.currentUser!.uid,
                      _cmnController.text);
                  _cmnController.clear();
                  scrollController.animateTo(
                    scrollController.position.minScrollExtent,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Image.asset(
                  AppImages.send,
                  scale: 5,
                ),
              ),
            )
          ],
        ),
        body: Container(
          width: double.infinity,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.bglight, AppColors.bgdark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 60),
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
                          border: Border.all(color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(AppSvgs.arrowback),
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.05),
                    CustomText(
                      title: 'Comments',
                      color: Colors.white,
                      size: 17.sp,
                      fontFamily: 'Poppins',
                      weight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1, color: AppColors.divider),
              !reelsController.commentsLoading
                  ? reelsController.videoList
                          .firstWhere(
                              (video) => video.videoId == widget.videoId)
                          .comments
                          .isNotEmpty
                      ? ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: reelsController.videoList
                              .firstWhere(
                                  (video) => video.videoId == widget.videoId)
                              .comments
                              .length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final video = reelsController.videoList.firstWhere(
                                (video) => video.videoId == widget.videoId);
                            List<CommentModel> comments = video.comments;
                            comments.sort(
                                (a, b) => b.createdAt.compareTo(a.createdAt));
                            CommentModel comment = comments[index];

                            print(
                                '........videocomment${reelsController.cmntCount}');
                            return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(children: [
                                  SizedBox(
                                    width: size.width * 0.12,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        comment.user?.image ??
                                            AppImages.profile,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 10, left: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: width * 0.7,
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.textFieledfillColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 0.45.sw,
                                                  child: CustomText(
                                                    title: comment
                                                        .user!.displayname,
                                                    color: Colors.white,
                                                    size: 12.sp,
                                                    fontFamily: 'Poppins',
                                                    weight: FontWeight.w400,
                                                  ),
                                                ),
                                                Flexible(
                                                    child: SizedBox(
                                                  width: 0.45.sw,
                                                  child: CustomText(
                                                    softWrap: true,
                                                    maxLines: 3,
                                                    textAlign: TextAlign.start,
                                                    title: comment.comment,
                                                    color: Colors.white,
                                                    size: 12.sp,
                                                    fontFamily: 'Poppins',
                                                    weight: FontWeight.w400,
                                                  ),
                                                )),
                                                if (comment
                                                    .replies.isNotEmpty) ...[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20.0),
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          child:
                                                              ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount: comment
                                                                .replies.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              ReplyModel reply =
                                                                  comment.replies[
                                                                      index];

                                                              return Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    CircleAvatar(
                                                                      backgroundImage:
                                                                          NetworkImage(
                                                                        reply.user?.image ??
                                                                            AppImages.profile,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        CustomText(
                                                                          title:
                                                                              reply.replyusername,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              12.sp,
                                                                          fontFamily:
                                                                              'Poppins',
                                                                          weight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              0.45.sw,
                                                                          child:
                                                                              CustomText(
                                                                            softWrap:
                                                                                true,
                                                                            maxLines:
                                                                                3,
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                            title:
                                                                                reply.replyText,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                12.sp,
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            weight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.02,
                                        ),
                                        Row(
                                          children: [
                                            CustomText(
                                              title: timeago.format(
                                                  comment.createdAt,
                                                  locale: 'en'),
                                              color: Colors.white,
                                              size: 12.sp,
                                              fontFamily: 'Poppins',
                                              weight: FontWeight.w500,
                                            ),
                                            SizedBox(
                                              width: width * 0.04,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                reelsController.likeComment(
                                                    widget.videoId,
                                                    comment.commentId,
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid);
                                              },
                                              child: Row(
                                                children: [
                                                  comment.likes.contains(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid)
                                                      ? const Icon(
                                                          Icons.favorite,
                                                          color: Colors.pink,
                                                          size: 17,
                                                        )
                                                      : const Icon(
                                                          Icons
                                                              .favorite_outline,
                                                          color: Colors.white,
                                                          size: 15,
                                                        ),
                                                  5.horizontalSpace,
                                                  CustomText(
                                                    title: reelsController
                                                        .formatLikesCount(
                                                            comment
                                                                .likes.length),
                                                    color: Colors.white,
                                                    size: 12.sp,
                                                    fontFamily: 'Poppins',
                                                    weight: FontWeight.w500,
                                                  ),
                                                  5.horizontalSpace,
                                                  CustomText(
                                                    title: 'Like',
                                                    color: Colors.white,
                                                    size: 12.sp,
                                                    fontFamily: 'Poppins',
                                                    weight: FontWeight.w500,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * 0.04,
                                            ),
                                            CustomText(
                                              title: 'Reply',
                                              color: Colors.white,
                                              size: 12.sp,
                                              fontFamily: 'Poppins',
                                              weight: FontWeight.w500,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ]));
                          })
                      : SizedBox(
                          height: .8.sh,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 0),
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
                                        'Comments people posted will appear\nhere.',
                                    color: AppColors.gray,
                                    size: 13.sp,
                                    fontFamily: 'Poppins',
                                    weight: FontWeight.w500,
                                  ),
                                  SizedBox(height: Get.height * 0.02),
                                  CustomText(
                                    title: 'Start commenting',
                                    color: AppColors.pink,
                                    size: 13.sp,
                                    fontFamily: 'Poppins',
                                    weight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                  : Container(
                      height: height,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 50),
                              child: CircularProgressIndicator(
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              30.verticalSpace
            ]),
          ),
        ),
      );
    });
  }
}
