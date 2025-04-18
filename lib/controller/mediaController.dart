import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../postDrip/post_drip1.dart';

class MediaController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late CameraController cameraController;
  late AnimationController controller;
  late List<CameraDescription> _cameras;
  bool isInitialized = false;
  RxBool isRecording = false.obs;
  XFile? _videoFile;
  File? _previewImage;
  // Future<void> initializeCamera() async {
  //   try {
  //     _cameras = await availableCameras();
  //     cameraController = CameraController(
  //       _cameras.first,
  //       ResolutionPreset.high,
  //     );
  //     await cameraController.initialize();
  //     isInitialized = true;
  //     log('Camera initialized successfully.');
  //   } catch (e) {
  //     log('Error initializing camera: $e');
  //   }
  // }

  Future<void> startVideoRecording() async {
    try {
      if (isRecording.value) {
        await cameraController.resumeVideoRecording();
      } else {
        await cameraController.startVideoRecording();
      }
      log('Recording started successfully.');
      isRecording.value = true;
    } catch (e) {
      log('Error starting video recording: $e');
    }
  }

  Future<void> stopVideoRecording() async {
    await cameraController.pauseVideoRecording();
  }

  endVideoRecording() async {
    log('Is recording? ${isRecording.value}');
    try {
      log('Stopping video recording...');

      XFile? video = await cameraController.stopVideoRecording();
      // await GallerySaver.saveVideo(filePath); //for testing
      // return video;
      log('Is video null? ${video == null}');

      if (video != null) {
        _videoFile = video;
        isRecording.value = false;

        log("Video file path: ${video.path}");

        if (_videoFile != null) {
          log('Navigating...');
          final thumbnail = await VideoThumbnail.thumbnailData(
            video: _videoFile!.path,
            maxWidth: 128,
            quality: 25,
          );

          final directory = await getTemporaryDirectory();
          Random rnd = Random();

          // Create the full file path
          final filePath = '${directory.path}/${rnd.nextInt(434236)}';

          // Write the Uint8List to a file
          final file2 = File(filePath);
          await file2.writeAsBytes(thumbnail!);
          Get.to(
            () => PostDrip1(
              thumbnail: file2,
              videoFile: _videoFile!,
              image: _previewImage ?? File(''),
            ),
          );
        }
      } else {
        log('Error: No video recorded');
      }
    } catch (e) {
      log('Error stopping video recording: $e');
    }
  }

  void resetRecording() {
    controller.reset();
    isRecording.value = false;
  }

  void startRecording() {
    // isRecording.value = true;
    controller.forward();
    startVideoRecording();
  }

  void stopRecording() {
    controller.stop();
    stopVideoRecording();
  }

  @override
  void onInit() {
    super.onInit();
    // initializeCamera();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void onClose() {
    cameraController.dispose();
    controller.dispose();
    super.onClose();
  }
}
