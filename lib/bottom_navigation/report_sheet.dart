import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drip_tok/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class ReportBottomSheet extends StatefulWidget {
  final String videoId;

  const ReportBottomSheet({super.key, required this.videoId});

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  String? selectedReason;

  List<String> reportReasons = [
    "Nudity or sexual content",
    "Hate speech or symbols",
    "Violent or graphic content",
    "Harassment or bullying",
    "Spam or misleading",
    "Other",
  ];

  void submitReport() {
    if (selectedReason != null) {
      // Navigator.pop(context);
      // Call your backend API here using widget.videoId and selectedReason
      print("Reported ${widget.videoId} for reason: $selectedReason");
      FirebaseFirestore.instance.collection('ReportedDrips').doc().set({
        'videoId': widget.videoId,
        'reason': selectedReason,
        'reportedBy': FirebaseAuth.instance.currentUser!.uid
      });
      Navigator.pop(context);

      Fluttertoast.showToast(
          msg: "Thanks for reporting. Our team will take appropriate action.",
          toastLength: Toast.LENGTH_LONG);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Get.width,
          height: 50,
          color: AppColors.bgdark,
          child: const Center(
            child: Text(
              "Why are you reporting this video?",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...reportReasons.map((reason) {
          return SizedBox(
            height: 30,
            child: RadioListTile<String>(
              title: Text(reason),
              value: reason,
              groupValue: selectedReason,
              onChanged: (value) {
                setState(() {
                  selectedReason = value;
                });
              },
            ),
          );
        }).toList(),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: selectedReason == null ? null : submitReport,
          child: Text("Submit Report"),
        ),
      ],
    );
  }
}
