import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/screens/comments.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/activities_controller.dart';
import '../controller/bottom_navigatio.dart';
import '../controller/reels_controller.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});
  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  final MyActivitiesController _controller = Get.find();
  late final ReelsController reelsController;
  @override
  void initState() {
    reelsController = Get.put(ReelsController());
    Future.delayed(const Duration(microseconds: 1), () {
      reelsController.videoControllerList.isNotEmpty
          ? reelsController.videoControllerList[0]?.pause()
          : null;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double height = size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bglight, AppColors.bgdark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: height * 0.1,
              width: double.infinity,
              decoration:
                  const BoxDecoration(color: AppColors.bottomnavigation),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
                child: Center(
                  child: CustomText(
                    title: 'Activities',
                    color: Colors.white,
                    size: 17.sp,
                    fontFamily: 'Poppins',
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_controller.userActivities.isEmpty) {
                  return const Center(
                    child: Text(
                      "No activities available",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _controller.userActivities.length,
                  itemBuilder: (context, index) {
                    final activity = _controller.userActivities[index];
                    print("Displaying Activity: ${activity['actiontitle']}");
                    return NotificationCard(
                      title: activity['actiontitle'] ?? 'No Title',
                      body: activity['actionbody'] ?? 'No Body',
                      videoId: activity['videoId'],
                      time: _controller
                          .formatTimestamp(activity['timestamp'] ?? 0),
                      activityId: activity['actionId'] ?? '',
                      onDelete: () async {
                        await _controller.deleteActivity(activity['actionId']);
                        _controller.userActivities.removeAt(index);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final String activityId;
  final String? videoId;

  final VoidCallback onDelete;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.body,
    this.videoId,
    required this.time,
    required this.activityId,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        if (title == 'Style') {
          Get.find<BottomNavBarProvider>().updateIndex(1);
        } else if (title == 'Comment') {
          Get.to(Comments(videoId: videoId ?? '', commentId: activityId));
        }
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(color: AppColors.bottomnavigation),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Image.asset(AppImages.notification,
                        height: height * 0.02),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            body,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  time,
                                  style: const TextStyle(
                                    color: Color(0xFF8D96B0),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF8D96B0), size: 20),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
