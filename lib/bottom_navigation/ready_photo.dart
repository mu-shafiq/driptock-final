import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drip_tok/Utils/share_app.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/controller/styleTransferController.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:saver_gallery/saver_gallery.dart';

class PhotoReadyScreen extends StatefulWidget {
  final int index;
  String styleid;
  PhotoReadyScreen({super.key, required this.index, required this.styleid});

  @override
  State<PhotoReadyScreen> createState() => _PhotoReadyScreenState();
}

class _PhotoReadyScreenState extends State<PhotoReadyScreen> {
  bool downloading = false;
  StyleTransferController styleTransferController = Get.find();
  late int displayedImageIndex;

  @override
  void initState() {
    super.initState();

    displayedImageIndex = widget.index;
  }

  // Save image to gallery
  void saveToGallery(String filePath) async {
    setState(() {
      downloading = true;
    });

    final result = await SaverGallery.saveImage(
      File(filePath).readAsBytesSync(),
      quality: 60,
      fileName: filePath.split('/').last.split('.').first,
      skipIfExists: false,
    );

    if (result.isSuccess == true) {
      setState(() {
        downloading = false;
      });
      Fluttertoast.showToast(msg: 'Image saved to gallery');
    } else {
      setState(() {
        downloading = false;
      });
      Fluttertoast.showToast(msg: 'Failed to download image to gallery');
    }
  }

  Future<void> updateCount(String type) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final uid = user!.uid;
      print(
          Get.find<StyleTransferController>().files[displayedImageIndex]['id']);

      DocumentReference styleDocRef = FirebaseFirestore.instance
          .collection('styles')
          .doc(Get.find<StyleTransferController>().files[displayedImageIndex]
              ['id']);
      final docSnapshot = await styleDocRef.get();

      if (docSnapshot.exists) {
        if (type == 'sharing') {
          await styleDocRef.update({
            'sharingCount': FieldValue.increment(1),
          });
        } else if (type == 'download') {
          await styleDocRef.update({
            'downloadCount': FieldValue.increment(1),
          });
        }

        print("Updated styleId: ${widget.styleid} for type: $type");
      } else {
        // Handle the case where the document does not exist
        print("Document with styleId: ${widget.styleid} does not exist");
      }
    } catch (e) {
      print("Error updating count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return Scaffold(
      body: GetBuilder<StyleTransferController>(
        builder: (styleTransferController) {
          final files = styleTransferController?.files ?? [];

          // Use files from the controller if available, otherwise use the default imageUrls
          final List<dynamic> imageList = files;
          return Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            padding: const EdgeInsets.all(3.0),
                            child: SvgPicture.asset(AppSvgs.arrowback),
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.05),
                      CustomText(
                        title: 'Your Photo is Ready',
                        color: Colors.white,
                        size: 15.sp,
                        fontFamily: 'Poppins',
                        weight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.03),
                Container(
                  height: height * 0.5,
                  width: width,
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(imageList[displayedImageIndex]['file'])
                          as ImageProvider,
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Builder(
                              builder: (BuildContext innerContext) {
                                return IconButton(
                                  icon: Image.asset(AppImages.share1,
                                      height: height * 0.05),
                                  onPressed: () => {
                                    shareImageFromPath(
                                      imagePath: styleTransferController
                                          .files[displayedImageIndex]['file']
                                          .path, 
                                      subject: 'Check out this image!',
                                      text: 'I found this image really cool.',
                                      context: innerContext,
                                    ),
                                    updateCount('sharing'),
                                  },
                                );
                              },
                            ),
                            SizedBox(height: height * 0.02),
                            InkWell(
                              onTap: () {
                                saveToGallery(styleTransferController
                                    .files[displayedImageIndex]['file'].path);
                                updateCount(
                                  'download',
                                );
                              },
                              child: downloading
                                  ? CircleAvatar(
                                      radius: size.height * .024,
                                      backgroundColor: const Color.fromARGB(
                                              255, 245, 225, 225)
                                          .withOpacity(.3),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                            color: AppColors.pink),
                                      ),
                                    )
                                  : Image.asset(AppImages.download,
                                      height: height * 0.05),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.03),
                Flexible(
                  child: Container(
                    height: height * 0.5,
                    decoration: const BoxDecoration(
                      color: AppColors.bottomnavigation,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: CustomText(
                              title: 'Recommended Style',
                              color: Colors.white,
                              size: 16.sp,
                              fontFamily: 'Poppins',
                              weight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(
                              height: height * 0.2,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: imageList.length,
                                  itemBuilder: (context, index) {
                                    return index == displayedImageIndex
                                        ? const SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    displayedImageIndex = index;
                                                  });
                                                },
                                                child: Container(
                                                  width: width * 0.4,
                                                  height: height * 0.6,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: FileImage(
                                                              imageList[index]
                                                                  ['file'])
                                                          as ImageProvider,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                  }))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
