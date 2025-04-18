import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

void shareLink(String text, BuildContext context) async {
  final box = context.findRenderObject() as RenderBox?;

  final scaffoldMessenger = ScaffoldMessenger.of(context);
  ShareResult shareResult;
  shareResult = await Share.share(
    text,
    subject: text,
    sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  );
  scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
}

SnackBar getResultSnackBar(ShareResult result) {
  return SnackBar(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.status == ShareResultStatus.success)
          const Text("Shared successfully"),
      ],
    ),
  );
}

 
Future<void> shareImageFromPath({
  required String imagePath,
  String? subject,
  String? text,
  required BuildContext context,
}) async {
  // Use context to get the RenderBox for proper popover positioning.
  final box = context.findRenderObject() as RenderBox?;
  if (box == null) {
    debugPrint('Error: Unable to determine share origin.');
    return;
  }

  // Create an XFile from the provided image path.
  final XFile imageFile = XFile(imagePath);

  try {
    // Share the image using shareXFiles.
    final ShareResult shareResult = await Share.shareXFiles(
      [imageFile],
      subject: subject,
      text: text,
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
    
    // Show a snackbar with the share result.
    ScaffoldMessenger.of(context).showSnackBar(_getResultSnackBar(shareResult));
  } catch (e) {
    debugPrint("Error sharing image: $e");
  }
}

/// Returns a SnackBar to display the share result.
SnackBar _getResultSnackBar(ShareResult result) {
  return SnackBar(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.status == ShareResultStatus.success)
          const Text("Shared successfully"),
        if (result.status != ShareResultStatus.success)
          const Text("Share canceled or failed"),
      ],
    ),
  );
}
