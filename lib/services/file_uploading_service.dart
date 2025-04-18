// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;

// class FileUploadingService {
//   Future<String?> uploadImage(File file) async {
//     // Replace this with your actual API key
//     var headers = {'Content-Type': 'image/png'};
//     var request = http.Request(
//       'POST',
//       Uri.parse(
//           'https://www.filestackapi.com/api/store/S3?key=Avve9lf66Q8uYI6P94B97z'),
//     );

//     // Read the file as bytes and assign it to the body
//     request.bodyBytes = await file.readAsBytes();

//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       // print(json.decode(await response.stream.bytesToString())['url']);
//       print('returning sucesss............');
//       return json.decode(await response.stream.bytesToString())['url'];
//     } else {
//       print(response.reasonPhrase);

//       return null;
//     }
//   }

//   Future<String?> uploadVideo(File file) async {
//     // Replace this with your actual API key
//     var headers = {'Content-Type': 'video/mp4'};
//     var request = http.Request(
//       'POST',
//       Uri.parse(
//           'https://www.filestackapi.com/api/store/S3?key=Avve9lf66Q8uYI6P94B97z'),
//     );

//     // Read the file as bytes and assign it to the body
//     request.bodyBytes = await file.readAsBytes();

//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       // print(json.decode(await response.stream.bytesToString())['url']);
//       return json.decode(await response.stream.bytesToString())['url'];
//     } else {
//       print(response.reasonPhrase);

//       return null;
//     }
//   }
// }
