import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drip_tok/controller/admin_controller.dart';
import 'package:drip_tok/controller/styleTransferController.dart';
import 'package:drip_tok/screens/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/reels_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';
import 'ready_photo.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import 'package:uuid/uuid.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

final List<String> imageUrls = [
  AppImages.group1,
  AppImages.group2,
  AppImages.group3,
  AppImages.group4,
  AppImages.group5,
  AppImages.group6,
];

class _ExploreState extends State<Explore> {
  late SharedPreferences prefs;
  late String styleId;
  late final StyleTransferController styleTransferController;
  late final ReelsController reelsController;
  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    styleTransferController = Get.put(StyleTransferController());
    Future.delayed(Duration.zero, () {
      if (styleTransferController.files.isEmpty) {
        styleTransferController.fetchStylesFromFirestore();
      }
    });

    reelsController = Get.put(ReelsController());
    Future.delayed(const Duration(microseconds: 1), () {
      reelsController.videoControllerList.isNotEmpty
          ? reelsController.videoControllerList[0]?.pause()
          : null;
    });
  }

  _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();

    styleId = prefs.getString('styleId') ?? '';
    setState(() {});
  }

  Future<void> _saveStyleId(String styleId) async {
    await prefs.setString('styleId', styleId);
    setState(() {
      this.styleId = styleId;
    });
  }

  Future<void> openGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      String fileName = Uuid().v4();

      Reference storageRef =
          FirebaseStorage.instance.ref().child('styles/$fileName');

      try {
        await storageRef.putFile(imageFile);
        String imageUrl = await storageRef.getDownloadURL();

        String userId = FirebaseAuth.instance.currentUser!.uid;

        String newStyleId = Uuid().v4();
        styleId = newStyleId;
        await _saveStyleId(styleId);
        setState(() {});
        await FirebaseFirestore.instance.collection('styles').doc(styleId).set({
          'userId': userId,
          'imageUrl': imageUrl,
          'styleId': styleId,
          'sharingCount': 0,
          'downloadCount': 0,
          'timestamp': FieldValue.serverTimestamp(),
        });
        styleTransferController.uploadToFirestore();
        print('Image uploaded successfully: $styleId');
        styleTransferController.clearStyles();
        // styleTransferController.fetchStylesFromFirestore();
        styleTransferController.update();
      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print('No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return GetBuilder<StyleTransferController>(
      builder: (controller) {
        return WillPopScope(
          onWillPop: () async {
            SystemNavigator.pop();
            return false;
          },
          child: Scaffold(
              body: Container(
            height: 1.sh,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bglight, AppColors.bgdark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      keyboardType: TextInputType.none,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Users(),
                            ));
                      },
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                    SizedBox(
                      height: height * 0.01,
                    ),
                    InkWell(
                      onTap: () {},
                      child: CustomText(
                        title: 'Recommend Style',
                        color: Colors.white,
                        size: 15.sp,
                        fontFamily: 'Poppins',
                        weight: FontWeight.w700,
                      ),
                    ),
                    styleTransferController.loading
                        ? SizedBox(
                            height: .6.sh,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.pink,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: .63.sh,
                            child: GridView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 0.185.sh,
                              ),
                              itemCount:
                                  styleTransferController.files.isNotEmpty
                                      ? styleTransferController.files.length
                                      : imageUrls.length,
                              itemBuilder: (context, index) {
                                final bool hasFiles =
                                    styleTransferController.files.isNotEmpty ==
                                        true;

                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: GestureDetector(
                                    onTap: () async {
                                      print('onTap triggered');

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PhotoReadyScreen(
                                            index: index,
                                            styleid: styleId,
                                          ),
                                        ),
                                      );
                                    },
                                    onLongPress: () {
                                      if (Get.find<AdminController>().isAdmin) {
                                        showDeleteDialogue(
                                            styleTransferController.files[index]
                                                ['id']);
                                      }
                                    },
                                    child: hasFiles
                                        ? Image.file(
                                            styleTransferController.files[index]
                                                ['file'],
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            imageUrls[index],
                                            fit: BoxFit.fill,
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    CustomButton(
                      text: 'Upload Photo',
                      textSize: 14,
                      fontWeight: FontWeight.w600,
                      onPressed: () async {
                        openGallery();
                        showAnalyzingDialog(context);
                        await Future.delayed(const Duration(seconds: 10));
                        styleTransferController.fetchStylesFromFirestore();
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: height * 0.02),
                  ],
                ),
              ),
            ),
          )),
        );
      },
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
                        title: 'Are you sure you want to delete this image?',
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

                                styleTransferController.deleteStyleWithId(id);
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

void showAnalyzingDialog(BuildContext context) {
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
            filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          AlertDialog(
            backgroundColor: AppColors.analyzing,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
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
                    height: height * 0.01,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: CustomText(
                      title: 'Analyzing Your photo',
                      fontFamily: 'Poppins',
                      weight: FontWeight.w500,
                      size: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Image.asset(
                    AppImages.analyzingPhoto,
                    width: width * 0.45,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
