import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/constants/bottom_navigation.dart';
import 'package:drip_tok/controller/reels_controller.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:rxdart/rxdart.dart';

class PostDrip3 extends StatefulWidget {
  final XFile videoFile;
  final File image;
  final File audioFile;
  final File thumbnail;

  const PostDrip3(
      {super.key,
      required this.image,
      required this.videoFile,
      required this.audioFile,
      required this.thumbnail});

  @override
  State<PostDrip3> createState() => _PostDrip3State();
}

class _PostDrip3State extends State<PostDrip3> {
  VideoPlayerController? _videoController;
  final progressStream = BehaviorSubject<WaveformProgress>();

  @override
  void initState() {
    log('init');
    widget.videoFile.path.isNotEmpty
        ? initializeVideoPlayer(File(widget.videoFile.path), false)
        : null;

    Future.delayed(Duration(seconds: 0), () {
      widget.image.path.isEmpty
          ? mergeAudioWithVideo(
              videoPath: widget.videoFile.path,
              audioPath: widget.audioFile.path,
            )
          : mergeAudioWithImage(
              imagePath: widget.image.path,
              audioPath: widget.audioFile.path,
            );
    });
    super.initState();
  }

  // final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();
  // final FlutterFFprobe _ffprobe = FlutterFFprobe();
  File? finalVideo;

  /// Merges an audio file with a video file, trimming the audio if necessary to match the video length.
  // Future<void> mergeAudioWithVideo({
  //   required String videoPath,
  //   required String audioPath,
  // }) async {
  //   try {
  //     showMergeInProgressDialog(context, 'Processing your video...');
  //     final Directory tempDir = await getTemporaryDirectory();
  //     String outputPath =
  //         '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

  //     // Fetch video and audio durations
  //     final videoInfo = await _ffprobe.getMediaInformation(videoPath);
  //     final audioInfo = await _ffprobe.getMediaInformation(audioPath);

  //     if (videoInfo == null || audioInfo == null) {
  //       throw Exception("Failed to retrieve media information.");
  //     }

  //     double videoDuration =
  //         double.tryParse(videoInfo.getMediaProperties()?['duration'] ?? '0') ??
  //             0;

  //     log('video duration is $videoDuration');
  //     double audioDuration =
  //         double.tryParse(audioInfo.getMediaProperties()?['duration'] ?? '0') ??
  //             0;

  //     // Build FFmpeg command
  //     String command;
  //     if (
  //         // audioDuration > videoDuration
  //         true) {
  //       command =
  //           "-r 15 -f mp4 -i '$videoPath' -i '$audioPath' -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -t 15 -y '$outputPath'";
  //     } else {
  //       command =
  //           "-i '$videoPath' -i '$audioPath' -c:v copy -c:a aac -strict experimental $outputPath";
  //     }

  //     // Execute FFmpeg command
  //     int result = await _ffmpeg.execute(command);
  //     if (result != 0) {
  //       throw Exception("FFmpeg failed with error code: $result");
  //     }

  //     await initializeVideoPlayer(File(outputPath), false);
  //     dismissMergeProgressDialog(context);
  //     _videoController!.play();
  //     log("Merge successful: $outputPath");
  //   } catch (e) {
  //     dismissMergeProgressDialog(context);
  //     Get.snackbar('Error', e.toString());
  //     log("Error: $e");
  //   }
  // }

  Future<void> mergeAudioWithVideo({
    required String videoPath,
    required String audioPath,
  }) async {
    try {
      showMergeInProgressDialog(context, 'Processing your video...');
      final Directory tempDir = await getTemporaryDirectory();
      String outputPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

      String command;
      if (true) {
        command =
            "-r 15 -f mp4 -i '$videoPath' -i '$audioPath' -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -t 15 -y '$outputPath'";
      } else {
        command =
            "-i '$videoPath' -i '$audioPath' -c:v copy -c:a aac -strict experimental $outputPath";
      }

      // Execute FFmpeg command
      FFmpegSession result = await FFmpegKit.execute(command);
      final returnCode = await result.getReturnCode();
      if (!ReturnCode.isSuccess(returnCode)) {
        throw Exception("FFmpeg failed with error code: $result");
      }

      await initializeVideoPlayer(File(outputPath), false);
      dismissMergeProgressDialog(context);
      _videoController!.play();
      log("Merge successful: $outputPath");
    } catch (e) {
      dismissMergeProgressDialog(context);
      Get.snackbar('Error', e.toString());
      log("Error: $e");
    }
  }

  // Future<void> mergeAudioWithImage({
  //   required String imagePath,
  //   required String audioPath,
  // }) async {
  //   try {
  //     showMergeInProgressDialog(context, 'Processing your video...');
  //     final Directory tempDir = await getTemporaryDirectory();
  //     String outputPath =
  //         '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

  //     // Fetch audio duration
  //     final imageInfo = await _ffprobe.getMediaInformation(imagePath);
  //     if (imageInfo == null) {
  //       throw Exception("Failed to retrieve audio information.");
  //     }
  //     log(imageInfo.getMediaProperties().toString());

  //     String command =
  //         "-r 15 -i '$audioPath' -f image2 -i '$imagePath' -vf 'scale=1280:720' -t 15 -y '$outputPath'";

  //     // Execute FFmpeg command
  //     int result = await _ffmpeg.execute(command);
  //     if (result != 0) {
  //       throw Exception("FFmpeg failed with error code: $result");
  //     }

  //     await initializeVideoPlayer(File(outputPath), true);
  //     dismissMergeProgressDialog(context);
  //     log("Merge successful: $outputPath");
  //   } catch (e) {
  //     dismissMergeProgressDialog(context);
  //     Get.snackbar('Error', e.toString());
  //     log("Error: $e");
  //   }
  // }

  Future<void> mergeAudioWithImage({
    required String imagePath,
    required String audioPath,
  }) async {
    try {
      showMergeInProgressDialog(context, 'Processing your video...');
      final Directory tempDir = await getTemporaryDirectory();
      String outputPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

      String command =
          "-r 15 -i '$audioPath' -f image2 -i '$imagePath' -vf 'scale=1280:720' -t 15 -y '$outputPath'";

      // Execute FFmpeg command
      FFmpegSession result = await FFmpegKit.execute(command);
      final returnCode = await result.getReturnCode();
      if (!ReturnCode.isSuccess(returnCode)) {
        throw Exception("FFmpeg failed with error code: $result");
      }

      await initializeVideoPlayer(File(outputPath), true);
      dismissMergeProgressDialog(context);
      log("Merge successful: $outputPath");
    } catch (e) {
      dismissMergeProgressDialog(context);
      Get.snackbar('Error', e.toString());
      log("Error: $e");
    }
  }

  initializeVideoPlayer(File video, bool isImage) async {
    final videoFile = video;
    finalVideo = videoFile;
    if (!videoFile.existsSync()) {
      log('Error: Video file not found at path: ${widget.videoFile.path}');
      return;
    } else {
      log('Video file found');
    }

    try {
      _videoController = VideoPlayerController.file(videoFile)
        ..initialize().then((_) {
          log('Video player initialized successfully');
          finalVideo = videoFile;
          setState(() {});
        }).catchError((error) {
          log('Error initializing video player: $error');
        })
        ..setLooping(true);
      log('Video player setup completed');
      _videoController!.addListener(() {
        setState(() {});
      });
      if (isImage) {
        _videoController?.play();
      }
    } catch (e) {
      log('Exception during video player initialization: $e');
    }
  }

  List<double> sample = [];

  void showMergeInProgressDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bgdark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.pink),
              ),
              const SizedBox(height: 20),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dismiss the dialog when merging is complete.
  void dismissMergeProgressDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
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

    return GetBuilder<ReelsController>(builder: (reelsController) {
      return SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              if (widget.image.existsSync())
                Positioned.fill(
                  child: Image.file(
                    widget.image,
                    fit: BoxFit.cover,
                  ),
                )
              else if (widget.videoFile != null &&
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
                const Center(
                  child: CircularProgressIndicator(),
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
                          padding: const EdgeInsets.only(
                              bottom: 40.0, left: 10, right: 10),
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => const PostDrip4(),
                              //     ));
                              _videoController!.value.isPlaying
                                  ? _videoController!.pause()
                                  : _videoController!.play();
                              setState(() {});
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _videoController != null &&
                                        _videoController!.value.isPlaying
                                    ? widget.image.path.isEmpty
                                        ? SizedBox(
                                            child: CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            radius: height * 0.02,
                                            child: const Icon(Icons.pause),
                                          ))
                                        : const SizedBox()
                                    : widget.image.path.isEmpty
                                        ? SizedBox(
                                            child: Image.asset(
                                            AppImages.recordd,
                                            height: height * 0.04,
                                          ))
                                        : const SizedBox(),
                                SizedBox(
                                  width: 0.02.sw,
                                ),
                                widget.image.path.isEmpty
                                    ? SizedBox(
                                        height: height * 0.05,
                                        child: Stack(
                                          children: [
                                            StreamBuilder<WaveformProgress>(
                                              stream: progressStream,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasError) {
                                                  return Center(
                                                    child: Text(
                                                      'Error: ${snapshot.error}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  );
                                                }
                                                final progress =
                                                    snapshot.data?.progress ??
                                                        0.0;
                                                final waveform =
                                                    snapshot.data?.waveform;
                                                log(waveform.toString());
                                                // if (waveform == null) {
                                                //   return Center(
                                                //     child: Text(
                                                //       '${(100 * progress).toInt()}%',
                                                //       style: Theme.of(context)
                                                //           .textTheme
                                                //           .titleLarge,
                                                //     ),
                                                //   );
                                                // }
                                                return SizedBox(
                                                  height: 100,
                                                  width: .7.sw,
                                                  child:
                                                      _videoController != null
                                                          ? WaveformWidget(
                                                              progress: _videoController!
                                                                      .value
                                                                      .position
                                                                      .inSeconds /
                                                                  _videoController!
                                                                      .value
                                                                      .duration
                                                                      .inSeconds,
                                                              currentTime:
                                                                  _videoController!
                                                                      .value
                                                                      .position,
                                                              duration:
                                                                  _videoController!
                                                                      .value
                                                                      .duration,
                                                            )
                                                          : const SizedBox(),
                                                );
                                              },
                                            ),
                                            Positioned(
                                                left: size.width * 0.075,
                                                child: SvgPicture.asset(
                                                  AppSvgs.record,
                                                )),
                                            Positioned(
                                                right: size.width * 0.12,
                                                child: SvgPicture.asset(
                                                    AppSvgs.record))
                                          ],
                                        ))
                                    : const SizedBox(),
                                SizedBox(
                                  width: 0.03.sw,
                                ),
                                InkWell(
                                    onTap: () async {
                                      // if (finalVideo != null) {
                                      showMergeInProgressDialog(
                                          context, 'Uploading...');
                                      _videoController != null
                                          ? await _videoController!.pause()
                                          : null;
                                      await reelsController.uploadVideo(
                                          finalVideo!,
                                          '',
                                          widget.thumbnail,
                                          widget.image.path.isNotEmpty);
                                      dismissMergeProgressDialog(context);
                                      Get.offAll(const MainScreen());
                                      // } else {
                                      //   Get.snackbar(
                                      //       'Error', 'Video not ready yet');
                                      // }
                                    },
                                    child: widget.image.path.isEmpty
                                        ? Image.asset(
                                            AppImages.send,
                                            height: height * 0.04,
                                          )
                                        : Container(
                                            height: 50,
                                            width: 150,
                                            decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                        255, 245, 225, 225)
                                                    .withOpacity(.3),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: const Center(
                                              child: Text(
                                                'Upload',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )),
                              ],
                            ),
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
    });
  }
}

class WaveformWidget extends StatelessWidget {
  final double progress; // Range: 0.0 to 1.0
  final Duration currentTime;
  final Duration duration;

  const WaveformWidget({
    Key? key,
    required this.progress,
    required this.currentTime,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bars =
        List.generate(80, (index) => (index / 80)); // Example waveform data

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.3),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            // Waveform visualization
            Expanded(
              child: Row(
                children: bars.map((value) {
                  final isHighlighted =
                      bars.indexOf(value) < progress * bars.length;
                  return Expanded(
                    child: Container(
                      height: 80 * value,
                      color: isHighlighted ? Colors.pinkAccent : Colors.white54,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                    ),
                  );
                }).toList(),
              ),
            ),
            5.horizontalSpace,

            // Timer
            Text(
              "${currentTime.inMinutes}:${(currentTime.inSeconds % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
