import 'package:drip_tok/bottom_navigation/activity.dart';
import 'package:drip_tok/bottom_navigation/my_drips.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/bottom_navigation/explore.dart';
import 'package:drip_tok/bottom_navigation/home_screen.dart';
import 'package:drip_tok/controller/bottom_navigatio.dart';
import 'package:drip_tok/controller/reels_controller.dart';
import 'package:drip_tok/postDrip/select_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final BottomNavBarProvider _bottomNavBarProvider = Get.find();

  final List<Widget> _screens = [
    const HomeScreen(),
    const Explore(),
    const Activity(),
    const MyDrips()
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: _screens[_bottomNavBarProvider.currentIndex.value],
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: CustomBottomNav(
            currentIndex: _bottomNavBarProvider.currentIndex.value,
            onTap: (i) async {
              if (i != 0) {
                if (Get.find<ReelsController>()
                    .videoControllerList
                    .isNotEmpty) {
                  await Get.find<ReelsController>()
                      .videoControllerList[
                          Get.find<ReelsController>().videoControllerIndex]
                      ?.pause();
                }
              }
              _bottomNavBarProvider.updateIndex(i);
            },
          ),
        ));
  }
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: height * .17,
          child: Container(
            margin: const EdgeInsets.only(top: 45),
            width: width,
            height: height * .1,
            decoration: const BoxDecoration(
              color: AppColors.bottomnavigation,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(37),
                topRight: Radius.circular(37),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) => onTap(index),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: AppColors.gray,
                  elevation: 0,
                  items: [
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        AppSvgs.home,
                        color:
                            currentIndex == 0 ? Colors.white : AppColors.gray,
                        height: height * 0.03,
                        width: width * 0.07,
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.search,
                        color:
                            currentIndex == 1 ? Colors.white : AppColors.gray,
                        size: height * 0.03,
                      ),
                      label: 'Explore',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        AppSvgs.activity,
                        color:
                            currentIndex == 2 ? Colors.white : AppColors.gray,
                        height: height * 0.03,
                        width: width * 0.07,
                      ),
                      label: 'Activity',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        AppSvgs.profile,
                        color:
                            currentIndex == 3 ? Colors.white : AppColors.gray,
                        height: height * 0.03,
                        width: width * 0.07,
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: height * 0.01,
          child: Container(
            height: height * 0.007,
            width: width * 0.4,
            decoration: BoxDecoration(
              color: AppColors.gray,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Positioned(
          bottom: height * 0.06,
          child: GestureDetector(
            onTap: () async {
              Get.find<ReelsController>().videoControllerList.isNotEmpty
                  ? await Get.find<ReelsController>()
                      .videoControllerList[
                          Get.find<ReelsController>().videoControllerIndex]
                      ?.pause()
                  : null;

              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraScreen(),
                  ));
            },
            child: SvgPicture.asset(
              AppSvgs.addNavigation,
              height: height * 0.07,
            ),
          ),
        ),
      ],
    );
  }
}
