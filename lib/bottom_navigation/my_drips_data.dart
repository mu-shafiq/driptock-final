// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:drip_tok/constants/app_colors.dart';
// import 'package:drip_tok/constants/app_images.dart';
// import 'package:drip_tok/widgets/custom_text.dart';
// import 'package:get/get.dart';

// import '../controller/user_data_controller.dart';
// import '../controller/user_profile_Controller.dart';

// class MyDripsData extends StatefulWidget {
//   const MyDripsData({super.key});

//   @override
//   State<MyDripsData> createState() => _MyDripsDataState();
// }

// class _MyDripsDataState extends State<MyDripsData> {
//   int selectedIndex = 0;

//   void _onContainerSelected(int index) {
//     setState(() {
//       selectedIndex = index;
//     });
//   }

//   int _selectedIndex = 0;
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   List<String> images = [
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//     AppImages.drips,
//   ];

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     double width = size.width;
//     double height = size.height;

//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppColors.bglight, AppColors.bgdark],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//             ),
//             child: Obx(
//               () {
//                 final userProfile =
//                     Get.find<UserProfileController>().profileModel.value;
//                 final usermodel =
//                     Get.find<UserDataController>().userModel.value;
//                 return Column(
//                   children: [
//                     Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Image.asset(
//                           AppImages.profile,
//                           width: width,
//                           height: height * 0.3,
//                           fit: BoxFit.cover,
//                         ),
//                         Positioned.fill(
//                           child: Image.asset(
//                             AppImages.shades,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(
//                               top: 50, right: 20, left: 150),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               CustomText(
//                                 title: 'My Profile',
//                                 color: Colors.white,
//                                 size: 18.sp,
//                                 fontFamily: 'Poppins',
//                                 weight: FontWeight.w600,
//                               ),
//                               SvgPicture.asset(AppSvgs.share_profile)
//                             ],
//                           ),
//                         ),
//                         Positioned(
//                           top: height * 0.24,
//                           left: width * 0.39,
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => const MyDripsData(),
//                                   ));
//                             },
//                             child: ClipOval(
//                               child: Image.network(
//                                 userProfile.image ?? '',
//                                 height: height * 0.1,
//                                 width: height * 0.1,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     Image.asset(
//                                   AppImages.profile,
//                                   height: height * 0.1,
//                                   width: height * 0.1,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                     SizedBox(height: height * 0.04),
//                     CustomText(
//                       title: userProfile.username ?? '',
//                       color: Colors.white,
//                       size: 14.sp,
//                       fontFamily: 'Poppins',
//                       weight: FontWeight.w700,
//                     ),
//                     CustomText(
//                       title: usermodel.email ?? '',
//                       color: Colors.white,
//                       size: 11.sp,
//                       fontFamily: 'Poppins',
//                       weight: FontWeight.w400,
//                     ),
//                     SizedBox(height: height * 0.02),
//                     FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: CustomText(
//                         textAlign: TextAlign.center,
//                         title:
//                             'Fashion designer creating unique, trendsetting\npieces with elegance and flair.',
//                         color: Colors.white,
//                         size: 13.sp,
//                         fontFamily: 'Poppins',
//                         weight: FontWeight.w400,
//                       ),
//                     ),
//                     SizedBox(height: height * 0.02),
//                     Container(
//                       height: height * 0.05,
//                       width: width * 0.75,
//                       decoration: BoxDecoration(
//                           color: AppColors.textFieledfillColor,
//                           borderRadius: BorderRadius.circular(10)),
//                       child: const Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text.rich(
//                               TextSpan(
//                                 children: [
//                                   TextSpan(
//                                     text: '211 ',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                       fontFamily: 'Poppins',
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: 'Followers',
//                                     style: TextStyle(
//                                       color: AppColors.gray,
//                                       fontSize: 14,
//                                       fontFamily: 'Poppins',
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Text.rich(
//                               TextSpan(
//                                 children: [
//                                   TextSpan(
//                                     text: '23 ',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                       fontFamily: 'Poppins',
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: 'Following',
//                                     style: TextStyle(
//                                       color: AppColors.gray,
//                                       fontSize: 14,
//                                       fontFamily: 'Poppins',
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: height * 0.02),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         GestureDetector(
//                           onTap: () => _onContainerSelected(0),
//                           child: Container(
//                             width: width * 0.42,
//                             height: height * 0.059,
//                             decoration: BoxDecoration(
//                               color: selectedIndex == 0
//                                   ? AppColors.pink
//                                   : AppColors.textFieledfillColor,
//                               borderRadius: BorderRadius.circular(25),
//                               border: Border.all(
//                                 color: selectedIndex == 0
//                                     ? AppColors.pink
//                                     : AppColors.textfieledBorder,
//                               ),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'My Drips',
//                                 style: TextStyle(
//                                   color: selectedIndex == 0
//                                       ? Colors.white
//                                       : AppColors.gray,
//                                   fontSize: 14,
//                                   fontFamily: "Poppins",
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 20),
//                         GestureDetector(
//                           onTap: () => _onContainerSelected(1),
//                           child: Container(
//                             width: width * 0.42,
//                             height: height * 0.059,
//                             decoration: BoxDecoration(
//                               color: selectedIndex == 1
//                                   ? AppColors.pink
//                                   : AppColors.textFieledfillColor,
//                               borderRadius: BorderRadius.circular(25),
//                               border: Border.all(
//                                 color: selectedIndex == 1
//                                     ? AppColors.pink
//                                     : AppColors.textfieledBorder,
//                               ),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Wardrobe',
//                                 style: TextStyle(
//                                   color: selectedIndex == 1
//                                       ? Colors.white
//                                       : AppColors.gray,
//                                   fontSize: 14,
//                                   fontFamily: "Poppins",
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: height * 0.02),
//                     const Divider(
//                       thickness: 1,
//                       color: AppColors.divider,
//                       endIndent: 10,
//                       indent: 10,
//                     ),
//                     Expanded(
//                       child: Center(
//                           child: selectedIndex == 0
//                               ? GridView.builder(
//                                   gridDelegate:
//                                       const SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount: 3,
//                                   ),
//                                   itemCount: images.length,
//                                   itemBuilder: (context, index) {
//                                     return Container(
//                                       margin: const EdgeInsets.only(
//                                           left: 5, right: 5, bottom: 5),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(4),
//                                         image: DecorationImage(
//                                           image: AssetImage(images[index]),
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 )
//                               : GridView.builder(
//                                   gridDelegate:
//                                       const SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount: 3,
//                                   ),
//                                   itemCount: images.length,
//                                   itemBuilder: (context, index) {
//                                     return Container(
//                                       margin: const EdgeInsets.only(
//                                           left: 5, right: 5, bottom: 5),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(4),
//                                         image: DecorationImage(
//                                           image: AssetImage(images[index]),
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 )),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
