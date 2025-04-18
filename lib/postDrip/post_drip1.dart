import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'package:camera/camera.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/postDrip/post_drip2.dart';
import 'package:drip_tok/widgets/custom_button.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class PostDrip1 extends StatefulWidget {
  final XFile videoFile;
  final File image;
  final File thumbnail;

  const PostDrip1(
      {super.key,
      required this.image,
      required this.videoFile,
      required this.thumbnail});

  @override
  State<PostDrip1> createState() => _PostDrip1State();
}

class _PostDrip1State extends State<PostDrip1> {
  VideoPlayerController? _videoController;
  XFile? videoFile;
  File? image;

  @override
  void initState() {
    super.initState();
    if (widget.videoFile.path.isNotEmpty) {
      compressVideo();
    } else {
      compressImage();
    }
  }

  compressImage() async {
    try {
      log('sized before compress ${(await widget.image.absolute.length()) / (1024 * 1024)}');
      var result = await FlutterImageCompress.compressWithFile(
        widget.image.absolute.path,

        quality: 94,
        // rotate: 90,
      );
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      Random rnd = Random();

      // Create a file
      File file = File('$tempPath/${rnd.nextInt(455532)}');

      // Write the Uint8List to the file
      await file.writeAsBytes(result!);
      setState(() {
        image = file;
      });
      log('sized after compress ${(await image!.absolute.length()) / (1024 * 1024)}');
      log('image compressed successfully...');
    } catch (e) {
      log('error while compressing image.. \n $e');

      setState(() {
        image = widget.image;
      });
    }
  }

  compressVideo() async {
    try {
      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        widget.videoFile.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false, // It's false by default
      );
      log('duee ${mediaInfo!.duration!}');
      VideoPlayerController videoPlayerController =
          VideoPlayerController.file(File(mediaInfo.file!.path))..initialize();
      if (videoPlayerController.value.duration.inSeconds! > 15) {
        Fluttertoast.showToast(msg: 'Video will be trimmed to 15 seconds');
      }
      videoPlayerController.dispose();
      log('video compressed successfulll..');
      setState(() {
        if (mediaInfo != null && mediaInfo.path!.isNotEmpty) {
          videoFile = XFile(mediaInfo.file!.path);
        } else {
          videoFile = widget.videoFile;
        }
      });
      initializeVideo();
    } catch (e) {
      log('error while compressing video.. \n $e');

      setState(() {
        videoFile = widget.videoFile;
      });
      initializeVideo();
    }
  }

  initializeVideo() {
    final video = File(videoFile!.path);
    if (!video.existsSync()) {
      log('Error: Video file not found at path: ${video.path}');
      return;
    } else {
      log('Video file found');
    }

    try {
      _videoController = VideoPlayerController.file(video)
        ..initialize().then((_) {
          log('Video player initialized successfully');
          setState(() {});
        }).catchError((error) {
          log('Error initializing video player: $error');
        })
        ..setLooping(true)
        ..play();
      log('Video player setup completed');
    } catch (e) {
      log('Exception during video player initialization: $e');
    }
  }

  @override
  void dispose() {
    log('Disposing VideoPlayerController');
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            if (image != null && image!.existsSync())
              Positioned.fill(
                child: Image.file(
                  widget.image,
                  fit: BoxFit.cover,
                ),
              )
            else if (videoFile != null &&
                _videoController != null &&
                _videoController!.value.isInitialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              )
            else
              Center(
                child: Container(
                  width: width,
                  height: height,
                  color: AppColors.bgdark,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      5.verticalSpace,
                      const Text(
                        'Processing...',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 30),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          log('Back button tapped');
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: height * 0.035,
                          width: width * 0.08,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: SvgPicture.asset(
                              AppSvgs.arrowback,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.05),
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
                const Spacer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.asset(
                        AppImages.dripShade,
                        width: width,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: SizedBox(
                                width: 0.45.sw,
                                child: CustomButton(
                                  textColor: Colors.white,
                                  text: 'Continue',
                                  textSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  onPressed: () {
                                    if (videoFile != null || image != null) {
                                      _videoController?.pause();
                                      log('Continue button tapped');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PostDrip2(
                                            videoFile: videoFile ?? XFile(''),
                                            image: image ?? File(''),
                                            thumbnail: widget.thumbnail,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Flexible(
                              child: SizedBox(
                                width: 0.45.sw,
                                child: CustomButton2(
                                  textColor: Colors.white,
                                  backgroundColor: const Color(0xFF6B6C77),
                                  borderColor: const Color(0xFFC9C9C9),
                                  text: 'Cancel',
                                  textSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  onPressed: () {
                                    log('Cancel button tapped');
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
