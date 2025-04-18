import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'package:camera/camera.dart';
import 'package:drip_tok/Utils/app_utils.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/postDrip/post_drip1.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../controller/image_video_selection.dart';
import '../controller/mediaController.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isInitialized = false;
  File? _previewImage;
  final SelectionController controller = Get.put(SelectionController());
  final MediaController mediaController = Get.put(MediaController());
  List<AssetEntity> images = [];
  List<AssetEntity> videos = [];

  XFile? _videoFile;
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    initializeCamera();
    fetchGalleryImages();
    fetchGalleryVideos();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
  }

  Future<void> fetchGalleryImages() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isNotEmpty) {
        final List<AssetEntity> media = await albums.first.getAssetListPaged(
          page: 0,
          size: 100,
        );
        debugPrint("Number of images fetched: ${media.length}");

        setState(() {
          images = media;
        });
      } else {
        debugPrint("No image albums found.");
        setState(() {
          images = [];
        });
      }
    } else {
      log('sending to settings from location fetch images');
      // PhotoManager.openSetting();
      Fluttertoast.showToast(
          msg:
              'Photo library access is required to upload your styles. Please enable photo access from Settings');
    }
  }

  Future<void> fetchGalleryVideos() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      final List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: RequestType.video);

      for (AssetPathEntity album in albums) {
        final List<AssetEntity> media =
            await album.getAssetListPaged(page: 0, size: 100);
        if (media.isNotEmpty) {
          print("Found videos in album: ${album.name}, Count: ${media.length}");
          setState(() {
            videos = media;
          });
          break;
        }
      }
    } else {
      log('sending to settings from location fetch videos');
      // PhotoManager.openSetting();
      Fluttertoast.showToast(
          msg:
              'Photo library access is required to upload your styles. Please enable photo access from Settings');
    }
  }

  void initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras.first,
      ResolutionPreset.high,
    );
    log('checking camera permission status..');
    Permission permission = Permission.camera;
    if (await permission.status.isDenied ||
        await permission.status.isPermanentlyDenied) {
      Fluttertoast.showToast(
          msg:
              'Camera access is required to capture and share your styles. Please enable camera access from Settings');
      log('permissions are denied');
      return;
    }
    log('initializing..');
    await _cameraController.initialize();
    // await _cameraController
    //     .lockCaptureOrientation(DeviceOrientation.portraitDown);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _controller.dispose();
    _previewImage = null;
    super.dispose();
  }

  void capturePhoto() async {
    try {
      final XFile photo = await _cameraController.takePicture();
      setState(() {
        _previewImage = File(photo.path);
      });
      debugPrint('..................${photo.path}');
      await Future.delayed(const Duration(seconds: 0));

      if (_previewImage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDrip1(
                thumbnail: _previewImage!,
                videoFile: _videoFile ?? XFile(''),
                image: _previewImage ?? File('')),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Widget> loadVideoThumbnail(AssetEntity assetEntity) async {
    try {
      final file = await assetEntity.file;
      if (file != null) {
        final thumbnail = await VideoThumbnail.thumbnailData(
          video: file.path,
          maxWidth: 128,
          quality: 25,
        );

        if (thumbnail != null) {
          return Image.memory(thumbnail, fit: BoxFit.cover);
        } else {
          return const Icon(Icons.error);
        }
      } else {
        return const Icon(Icons.error);
      }
    } catch (e) {
      print("Error generating thumbnail: $e");
      return const Icon(Icons.error);
    }
  }

  Future<Widget> loadImageThumbnail(AssetEntity assetEntity) async {
    final thumbnail =
        await assetEntity.thumbnailDataWithSize(const ThumbnailSize(100, 100));
    if (thumbnail != null) {
      return Image.memory(thumbnail, fit: BoxFit.cover);
    } else {
      print("Failed to load thumbnail for asset: ${assetEntity.id}");
      return Container();
    }
  }

  void selectImageFromGallery(AssetEntity assetEntity) async {
    final file = await assetEntity.file;
    if (file != null) {
      setState(() {
        _previewImage = file;
      });

      await Future.delayed(const Duration(seconds: 0));

      if (_previewImage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDrip1(
              thumbnail: _previewImage!,
              videoFile: XFile(''),
              image: _previewImage ?? File(''),
            ),
          ),
        );
      }
    }
  }

  void selectVideoFromGallery(
    File file,
    File thumbnail,
  ) async {
    if (file != null) {
      await Future.delayed(const Duration(seconds: 0));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDrip1(
            thumbnail: thumbnail,
            videoFile: XFile(file.path),
            image: File(''),
          ),
        ),
      );
    }
  }

  Future<void> openGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _previewImage = File(pickedFile.path);
      });
      await Future.delayed(const Duration(seconds: 0));

      if (_previewImage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDrip1(
              thumbnail: _previewImage!,
              videoFile: _videoFile ?? XFile(''),
              image: _previewImage ?? File(''),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    double screenheight = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenheight < 700;
    print('..........the height of screen is $height');
    return Scaffold(
      backgroundColor: AppColors.bgdark,
      body: Obx(
        () => Column(
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    _isInitialized
                        ? SizedBox(
                            height: (controller.selectedIndex.value == 0
                                    ? images.isEmpty
                                    : videos.isEmpty)
                                ? .8.sh
                                : .7.sh,
                            width: width,
                            child: CameraPreview(_cameraController),
                          )
                        // : _previewImage != null
                        //     ? Container(
                        //         height: isSmallScreen ? 0.4.sh : 0.6.sh,
                        //         width: width,
                        //         decoration: BoxDecoration(
                        //           image: DecorationImage(
                        //             image: FileImage(_previewImage!),
                        //             fit: BoxFit.cover,
                        //           ),
                        //         ),
                        //       )
                        //     : _videoFile != null
                        //         ? SizedBox(
                        //             height: isSmallScreen ? 0.4.sh : 0.6.sh,
                        //             width: width,
                        //             child: VideoPlayer(
                        //               VideoPlayerController.file(
                        //                 File(_videoFile!.path),
                        //               )..initialize().then((_) {
                        //                   setState(() {});
                        //                 }),
                        //             ),
                        //           )
                        //         : const SizedBox.shrink(),
                        : SizedBox(
                            height: .7.sh,
                          ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 20.w, top: 60.h, right: 20.w),
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
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: Colors.white),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(3.0.r),
                                child: SvgPicture.asset(AppSvgs.arrowback),
                              ),
                            ),
                          ),
                          SizedBox(width: 0.05.sw),
                          CustomText(
                            title: 'Post drip',
                            color: Colors.white,
                            size: 18.sp,
                            fontFamily: 'Poppins',
                            weight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: height * 0.015,
            ),
            Container(
              height: height * 0.007,
              width: width * 0.12,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
            SizedBox(height: height * 0.015),
            controller.selectedIndex.value == 0
                ? images.isEmpty
                    ? const SizedBox()
                    : SizedBox(
                        height: 0.09.sh,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () =>
                                  selectImageFromGallery(images[index]),
                              child: FutureBuilder<Widget>(
                                future: loadImageThumbnail(images[index]),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5.w),
                                      width: 0.2
                                          .sw, // Ensures width scales proportionally
                                      height: 0.1
                                          .sh, // Ensures height scales proportionally

                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            8.0.r), // Scaled radius
                                        child: snapshot.data!,
                                      ),
                                    );
                                  } else {
                                    return SizedBox(
                                      width: 0.2.sw, // Placeholder width
                                      height: 0.1.sh, // Placeholder height
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      )
                : videos.isEmpty
                    ? const SizedBox()
                    : SizedBox(
                        height: 0.09.sh,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                final file = await videos[index].file;
                                if (file != null) {
                                  final thumbnail =
                                      await VideoThumbnail.thumbnailData(
                                    video: file.path,
                                    maxWidth: 128,
                                    quality: 25,
                                  );

                                  final directory =
                                      await getTemporaryDirectory();
                                  Random rnd = Random();

                                  // Create the full file path
                                  final filePath =
                                      '${directory.path}/${rnd.nextInt(434236)}';

                                  // Write the Uint8List to a file
                                  final file2 = File(filePath);
                                  await file2.writeAsBytes(thumbnail!);
                                  selectVideoFromGallery(file, file2);
                                }
                              },
                              child: FutureBuilder<Widget>(
                                future: loadVideoThumbnail(videos[index]),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5.w),
                                      width: 0.2
                                          .sw, // Ensures width scales proportionally
                                      height: 0.1
                                          .sh, // Ensures height scales proportionally
                                      decoration: BoxDecoration(
                                        border: _previewImage != null &&
                                                images[index].file ==
                                                    _previewImage
                                            ? Border.all(
                                                color: AppColors.pink,
                                                width: 3
                                                    .w, // Responsive border width
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(
                                            8.r), // Scaled radius
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            8.0.r), // Scaled radius
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                                width: 100,
                                                child: snapshot.data!),
                                            const Icon(Icons.play_arrow)
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return SizedBox(
                                      width: 0.2.sw,
                                      height: 0.1.sh,
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
            SizedBox(
              height: 0.01.sh,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: openGallery,
                      child: Image.asset(AppImages.image, height: 40.h),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (controller.selectedIndex.value == 0) {
                          capturePhoto();
                        } else {
                          if (mediaController.isRecording.value) {
                            // mediaController.startRecording();
                            mediaController.endVideoRecording();
                            mediaController.resetRecording();
                          } else {}
                        }
                      },
                      onLongPressStart: (LongPressStartDetails details) {
                        if (controller.selectedIndex.value == 1) {
                          mediaController.startRecording();
                        }
                      },
                      onLongPressEnd: (LongPressEndDetails details) async {
                        if (controller.selectedIndex.value == 1) {
                          mediaController.stopRecording();
                          // mediaController.resetRecording();
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Obx(() {
                            if (mediaController.isRecording.value) {
                              return AnimatedBuilder(
                                animation: mediaController.controller,
                                builder: (context, child) {
                                  return SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: CircularProgressIndicator(
                                      value: mediaController.controller.value,
                                      strokeWidth: 14.0,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Colors.red,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                          CircleAvatar(
                            backgroundColor: mediaController.isRecording.value
                                ? Colors.transparent
                                : Colors.white,
                            radius: 35,
                            child: mediaController.isRecording.value
                                ? const Icon(
                                    Icons.stop,
                                    color: Colors.red,
                                    size: 50,
                                  )
                                : Image.asset(
                                    AppImages.video,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final lensDirection =
                            _cameraController.description.lensDirection;
                        CameraDescription newCamera = _cameras.firstWhere(
                          (camera) => camera.lensDirection != lensDirection,
                        );
                        _cameraController = CameraController(
                          newCamera,
                          ResolutionPreset.high,
                        );
                        await _cameraController.initialize();
                        setState(() {});
                      },
                      child: Image.asset(
                        AppImages.camera,
                        height: 40.h,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: controller.selectedIndex.value == 0 ? 70 : 0),
              child: SizedBox(
                width: width,
                height: 15,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      left:
                          controller.selectedIndex.value == 0 ? 0 : width * 0.1,
                      right: controller.selectedIndex.value == 1
                          ? width * 0.25
                          : 0,
                      child: GestureDetector(
                        onTap: () {
                          controller.selectItem(0);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(
                              right: 65), // Add space to the right
                          child: CustomText(
                            title: 'Photo',
                            color: controller.selectedIndex.value == 0
                                ? Colors.white
                                : AppColors.gray,
                            size: 14.sp,
                            fontFamily: 'Poppins',
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      left:
                          controller.selectedIndex.value == 1 ? 0 : width * 0.2,
                      right: controller.selectedIndex.value == 0
                          ? width * 0.2
                          : 40,
                      child: GestureDetector(
                        onTap: () {
                          controller.selectItem(1);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 40),
                          child: CustomText(
                            title: 'Video',
                            color: controller.selectedIndex.value == 1
                                ? Colors.white
                                : AppColors.gray,
                            size: 14.sp,
                            fontFamily: 'Poppins',
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Container(
              width: 50,
              height: 2,
              color: AppColors.pink,
            ),
          ],
        ),
      ),
    );
  }
}
