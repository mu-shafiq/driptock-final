// import 'dart:developer';
// import 'dart:io';
// import 'dart:math' hide log;
// import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:drip_tok/constants/app_images.dart';
// import 'package:drip_tok/controller/user_profile_Controller.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:http/http.dart' as http;

// class StyleTransferController extends GetxController {
//   late Interpreter interpreterTransform;
//   late Interpreter interpreterPrediction;

//   static const int MODEL_TRANSFER_IMAGE_SIZE = 384;
//   static const int MODEL_PREDICTION_IMAGE_SIZE = 256;
//   List<File> files = [];
//   bool loading = false;

//   Future<void> loadModel() async {
//     interpreterTransform = await Interpreter.fromAsset(
//       'assets/models/transfer_model.tflite',
//     );
//     interpreterPrediction =
//         await Interpreter.fromAsset('assets/models/prediction_model.tflite');

//     log('1');
//   }

//   Future<Uint8List> transfer(Uint8List originData, Uint8List styleData) async {
//     var originImage = img.decodeImage(originData);
//     var modelTransferImage = img.copyResize(originImage!,
//         width: MODEL_TRANSFER_IMAGE_SIZE, height: MODEL_TRANSFER_IMAGE_SIZE);
//     var modelTransferInput = _imageToByteListUInt8(
//         modelTransferImage, MODEL_TRANSFER_IMAGE_SIZE, 0, 255);

//     var styleImage = img.decodeImage(styleData);

//     // style_image 256 256 3
//     var modelPredictionImage = img.copyResize(styleImage!,
//         width: MODEL_PREDICTION_IMAGE_SIZE,
//         height: MODEL_PREDICTION_IMAGE_SIZE);

//     // content_image 384 384 3
//     var modelPredictionInput = _imageToByteListUInt8(
//         modelPredictionImage, MODEL_PREDICTION_IMAGE_SIZE, 0, 255);

//     // style_image 1 256 256 3
//     var inputsForPrediction = [modelPredictionInput];
//     // style_bottleneck 1 1 100
//     var outputsForPrediction = Map<int, Object>();
//     var styleBottleneck = [
//       [
//         [List.generate(100, (index) => 0.0)]
//       ]
//     ];
//     outputsForPrediction[0] = styleBottleneck;

//     interpreterPrediction.runForMultipleInputs(
//         inputsForPrediction, outputsForPrediction);

//     var inputsForStyleTransfer = [modelTransferInput, styleBottleneck];

//     var outputsForStyleTransfer = Map<int, Object>();
//     var outputImageData = [
//       List.generate(
//         MODEL_TRANSFER_IMAGE_SIZE,
//         (index) => List.generate(
//           MODEL_TRANSFER_IMAGE_SIZE,
//           (index) => List.generate(3, (index) => 0.0),
//         ),
//       ),
//     ];
//     outputsForStyleTransfer[0] = outputImageData;

//     interpreterTransform.runForMultipleInputs(
//         inputsForStyleTransfer, outputsForStyleTransfer);

//     var outputImage =
//         _convertArrayToImage(outputImageData, MODEL_TRANSFER_IMAGE_SIZE);
//     var rotateOutputImage = img.copyRotate(outputImage, 90);
//     var flipOutputImage = img.flipHorizontal(rotateOutputImage);
//     var resultImage = img.copyResize(flipOutputImage,
//         width: originImage.width, height: originImage.height);

//     return Uint8List.fromList(img.encodeJpg(resultImage));
//   }

//   img.Image _convertArrayToImage(
//       List<List<List<List<double>>>> imageArray, int inputSize) {
//     img.Image image = img.Image.rgb(inputSize, inputSize);
//     for (var x = 0; x < imageArray[0].length; x++) {
//       for (var y = 0; y < imageArray[0][0].length; y++) {
//         var r = (imageArray[0][x][y][0] * 255).toInt();
//         var g = (imageArray[0][x][y][1] * 255).toInt();
//         var b = (imageArray[0][x][y][2] * 255).toInt();
//         image.setPixelRgba(x, y, r, g, b);
//       }
//     }

//     return image;
//   }

//   Future<void> _uploadToFirestore() async {
//     try {
//       final userId = FirebaseAuth.instance.currentUser?.uid;
//       String activityId =
//           FirebaseFirestore.instance.collection('activities').doc().id;
//       if (userId != null) {
//         await FirebaseFirestore.instance.collection('activities').add({
//           'actionId': activityId,
//           'actiontitle': 'Style',
//           'actionbody':
//               'We analyzed your photo and found style that perfectly suit your look-explore now',
//           'actionOwnerId': userId,
//           'timestamp': Timestamp.now(),
//         });
//         print('Document uploaded successfully');
//       } else {
//         print('No user is logged in');
//       }
//     } catch (e) {
//       print('Error uploading document: $e');
//     }
//   }

//   Uint8List _imageToByteListUInt8(
//     img.Image image,
//     int inputSize,
//     double mean,
//     double std,
//   ) {
//     var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
//     var buffer = Float32List.view(convertedBytes.buffer);
//     int pixelIndex = 0;

//     for (var i = 0; i < inputSize; i++) {
//       for (var j = 0; j < inputSize; j++) {
//         var pixel = image.getPixel(j, i);
//         buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
//         buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
//         buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
//       }
//     }
//     return convertedBytes.buffer.asUint8List();
//   }

//   Future<ByteData> downloadImageAsUint8List() async {
//     try {
//       // Perform HTTP GET request
//       String imageUrl =
//           Get.find<UserProfileController>().profileModel.value.image!;
//       final response = await http.get(Uri.parse(imageUrl));

//       // Check if the request was successful
//       if (response.statusCode == 200) {
//         Uint8List uint8List = response.bodyBytes;
//         return ByteData.view(uint8List.buffer);
//       } else {
//         throw Exception(
//             'Failed to download image. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error downloading image: $e');
//     }
//   }

//   generateMultipleStyles({File? file}) async {
//     loading = true;

//     update();
//     final List<String> styles = [
//       AppImages.group1,
//       AppImages.group2,
//       AppImages.group3,
//       AppImages.group4,
//       AppImages.group5,
//       AppImages.group6,
//     ];
//     var buf = file != null ? await file.readAsBytes() : null;
//     ByteData content = file == null
//         ? await downloadImageAsUint8List()
//         : ByteData.view(buf!.buffer);
//     await loadModel();
//     log('2');

//     List<Uint8List> styleImages = [];
//     for (var stylePath in styles) {
//       final ByteData styleData = await rootBundle.load(stylePath);
//       styleImages.add(styleData.buffer.asUint8List());
//     }
//     final ByteData styleData = content;

//     Uint8List contentImage = styleData.buffer.asUint8List();
//     files.clear();

//     for (var styleImage in styleImages) {
//       final directory = await getTemporaryDirectory();
//       Random rnd = Random();

//       // Define the file path
//       final filePath = '${directory.path}/${rnd.nextInt(4356765)}.png';
//       final styledImage = await transfer(contentImage, styleImage);
//       log('file generated successfully');
//       files.add(await File(filePath).writeAsBytes(styledImage));
//       loading = false;
//       update();
//     }
//     file != null ? Get.back() : null;
//     _uploadToFirestore();

//     loading = false;
//     update();
//   }
// }
