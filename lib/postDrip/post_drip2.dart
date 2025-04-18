import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:drip_tok/constants/app_images.dart';
import 'package:drip_tok/postDrip/post_drip3.dart';
import 'package:drip_tok/widgets/custom_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_sound/flutter_sound.dart';

class PostDrip2 extends StatefulWidget {
  final XFile videoFile;
  final File image;
  final File thumbnail;

  const PostDrip2(
      {super.key,
      required this.image,
      required this.videoFile,
      required this.thumbnail});

  @override
  State<PostDrip2> createState() => _PostDrip2State();
}

class _PostDrip2State extends State<PostDrip2>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  File? audioFile;
  bool recording = false;
  late AnimationController controller;
  FlutterSoundRecorder? _audioRecorder;
  final record = AudioRecorder();
  File? emptyAudioFile;

  @override
  void initState() {
    super.initState();
    loadAndSaveAudioFile();
    controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _audioRecorder = FlutterSoundRecorder();
    _audioRecorder!.openRecorder();

    final videoFile = File(widget.videoFile.path);
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

  Future<void> startRecording() async {
    log('in func...........');
    final Directory tempDir = await getTemporaryDirectory();
    Random rnd = Random();
    String subDir = rnd.nextInt(565433).toString();
    String outputPath = Platform.isIOS
        ? '${tempDir.path}/$subDir/audio.m4a'
        : '${tempDir.path}/$subDir/audio.mp3';

    final Directory recordingDir = Directory('${tempDir.path}/$subDir');
    if (!recordingDir.existsSync()) {
      recordingDir.createSync(recursive: true);
      log('Directory created: ${recordingDir.path}');
    }
    if (await record.hasPermission()) {
      log('starting..........');
      try {
        await record.start(const RecordConfig(), path: outputPath);
        log('recording....');
      } catch (e) {
        log('Error starting recording: $e');
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text('Allow microphone permission to record voice.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> stopRecording() async {
    final path = await record.stop();
    log('path : $path');

    if (_videoController != null) {
      await _videoController!.pause();
    }
    if (path == null || path.isEmpty) {
      log('No audio file recorded.');
      return;
    }
    // Add a slight delay (especially for iOS).
    await Future.delayed(const Duration(milliseconds: 300));
    bool? result = await showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (context) => AudioPickerDialog(
        audioPath: path,
        thumbnail: widget.thumbnail,
        image: widget.image,
        videoFile: widget.videoFile,
      ),
    );
  }

  // Future<String> trimAudio(
  //   String inputPath,
  // ) async {
  //   Directory tempDir = await getTemporaryDirectory();
  //   String tempPath = tempDir.path;
  //   Random rnd = Random();
  //
  //   // Create a file
  //   File file = File('$tempPath/${rnd.nextInt(889823)}');
  //   log('inn input path $inputPath');
  //   log('inn output path ${file.path}');
  //
  //   String command =
  //       '-i "$inputPath" -ss 00:00:00 -t 00:00:20 -c copy "${file.path}"';
  //
  //   FlutterFFmpeg().execute(command).then((session) async {
  //     if (session == 0) {
  //       print("✅ Audio trimmed successfully: ${file.path}");
  //     } else {
  //       print("❌ Error trimming audio: $session");
  //     }
  //   });
  //
  //   return file.path;
  // }

  Future<int?> getAudioDuration(String filePath) async {
    final player = AudioPlayer();
    try {
      await player.play(DeviceFileSource(filePath));
      Duration? duration = await player.getDuration();
      return duration!.inSeconds;
    } catch (e) {
      return null;
    } finally {
      player.dispose();
    }
  }

  pickAudioFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    PlatformFile? pfile = result?.files.first;
    File file;
    int? duration = await getAudioDuration(pfile!.path!);
    if (duration != null && duration > 20) {
      Fluttertoast.showToast(msg: 'Audio will be trimmed to 20 seconds');
      file = File(pfile.path!);
      log('inn returned from trimmer..');
    } else {
      file = File(pfile.path!);
    }
    log('inn out');

    if (File(file.path).existsSync()) {
      log('inn esits');

      setState(() {
        audioFile = File(file.path);
      });
      bool? result = await showDialog(
        context: context,
        useRootNavigator: true,
        builder: (context) => AudioPickerDialog(
          audioPath: file.path,
          thumbnail: widget.thumbnail,
          image: widget.image,
          videoFile: widget.videoFile,
        ),
      );
    } else {
      audioFile = null;
    }
  }

  @override
  void dispose() {
    log('Disposing VideoPlayerController');
    _videoController?.dispose();
    _audioRecorder!.closeRecorder();
    controller.dispose();
    super.dispose();
  }

  Future<void> loadAndSaveAudioFile() async {
    // Load the audio file from assets
    final ByteData data = await rootBundle.load('assets/sound/silent.mp3');
    final buffer = data.buffer.asUint8List();

    // Get the app's documents directory
    final directory = await getApplicationDocumentsDirectory();
    Random rnd = Random();

    // Create a file in the documents directory
    final soundDirectory = Directory('${directory.path}/sound');

    // Create the directory if it doesn't exist
    if (!await soundDirectory.exists()) {
      await soundDirectory.create(recursive: true);
    }

    // Create a file in the sound directory
    final file = File('${soundDirectory.path}/${rnd.nextInt(2398625)}.mp3');

    // Write the audio data to the file
    await file.writeAsBytes(buffer);

    emptyAudioFile = file; // Return the saved file
  }

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

  void dismissMergeProgressDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
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
                            child: SvgPicture.asset(AppSvgs.arrowback),
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
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (_videoController != null) {
                                  await _videoController!.pause();
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDrip3(
                                      videoFile: widget.videoFile,
                                      thumbnail: widget.thumbnail,
                                      image: widget.image,
                                      audioFile: emptyAudioFile!,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  SizedBox(
                                    child: Container(
                                      width: 55,
                                      height: height * 0.08,
                                      decoration: BoxDecoration(
                                          color: const Color(0xff89838a),
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.white)),
                                      child: const Icon(
                                        Icons.upload,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  CustomText(
                                    title: 'Post',
                                    color: Colors.white,
                                    size: 14.sp,
                                    fontFamily: 'Poppins',
                                    weight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 0.08.sw,
                            ),
                            GestureDetector(
                              onLongPressStart:
                                  (LongPressStartDetails details) {
                                setState(() {
                                  recording = true;
                                });
                                startRecording();
                              },
                              onLongPressEnd:
                                  (LongPressEndDetails details) async {
                                setState(() {
                                  recording = false;
                                });
                                stopRecording();
                              },
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      recording
                                          ? AnimatedBuilder(
                                              animation: controller,
                                              builder: (context, child) {
                                                return SizedBox(
                                                  width: 70,
                                                  height: 70,
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: controller.value,
                                                    strokeWidth: 14.0,
                                                    valueColor:
                                                        const AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.red,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : const SizedBox.shrink(),
                                      CircleAvatar(
                                        backgroundColor: recording
                                            ? Colors.transparent
                                            : Colors.white,
                                        radius: 30,
                                        child: recording
                                            ? const Icon(
                                                Icons.stop,
                                                color: Colors.red,
                                                size: 50,
                                              )
                                            : Image.asset(
                                                AppImages.record,
                                                fit: BoxFit.cover,
                                              ),
                                      )
                                    ],
                                  ),
                                  CustomText(
                                    title: 'Voice Record',
                                    color: Colors.white,
                                    size: 14.sp,
                                    fontFamily: 'Poppins',
                                    weight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 0.08.sw,
                            ),
                            GestureDetector(
                              onTap: () {
                                pickAudioFile();
                              },
                              child: Column(
                                children: [
                                  SizedBox(
                                    child: Image.asset(
                                      AppImages.import,
                                      height: height * 0.07,
                                    ),
                                  ),
                                  CustomText(
                                    title: 'Import',
                                    color: Colors.white,
                                    size: 14.sp,
                                    fontFamily: 'Poppins',
                                    weight: FontWeight.w600,
                                  ),
                                ],
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

// The updated AudioPickerDialog widget:

class AudioPickerDialog extends StatefulWidget {
  final String audioPath;
  final XFile videoFile;
  final File image;
  final File thumbnail;

  const AudioPickerDialog({
    super.key,
    required this.audioPath,
    required this.videoFile,
    required this.image,
    required this.thumbnail,
  });

  @override
  State<AudioPickerDialog> createState() => _AudioPickerDialogState();
}

class _AudioPickerDialogState extends State<AudioPickerDialog> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _audioDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _audioDuration = duration;
      });
    });
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
      if (position.inSeconds > 20) {
        _stopAudio();
      }
    });
  }

  Future<void> _playAudio() async {
    await _audioPlayer.play(DeviceFileSource(widget.audioPath));
    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _currentPosition = Duration.zero;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap AlertDialog with Material for proper theming on iOS.
    return Material(
      color: Colors.transparent,
      child: AlertDialog(
        backgroundColor: AppColors.bgdark,
        title: const Text(
          'Play Your File..',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Playing: ${widget.audioPath.split('/').last}',
              style: const TextStyle(color: Colors.white),
            ),
            Slider(
              value: _currentPosition.inSeconds.toDouble(),
              min: 0,
              max: _audioDuration.inSeconds > 0
                  ? _audioDuration.inSeconds.toDouble()
                  : 22,
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await _audioPlayer.seek(position);
                setState(() {
                  _currentPosition = position;
                });
              },
            ),
            // Display current seconds on the left and total seconds on the right.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentPosition.inSeconds}s',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  '${_audioDuration.inSeconds}s',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            // Toggle button row: shows play button when paused, pause button when playing.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    if (_isPlaying) {
                      await _pauseAudio();
                    } else {
                      await _playAudio();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.stop,
                    color: Colors.white,
                  ),
                  onPressed: _stopAudio,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _pauseAudio();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDrip3(
                    videoFile: widget.videoFile,
                    thumbnail: widget.thumbnail,
                    image: widget.image,
                    audioFile: File(widget.audioPath),
                  ),
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
