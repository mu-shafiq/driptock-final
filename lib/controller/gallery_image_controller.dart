import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import '../postDrip/post_drip1.dart';

class GalleryImageController extends GetxController {
  var previewImage = Rxn<File>();
  var videoFile = Rxn<XFile>();
  var images = <AssetEntity>[].obs;

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

  Future<void> selectImageFromGallery(AssetEntity assetEntity) async {
    final file = await assetEntity.file;
    if (file != null) {
      previewImage.value = file;

      if (previewImage.value != null) {
        Get.to(() => PostDrip1(
              thumbnail: previewImage.value!,
              videoFile: videoFile.value ?? XFile(''),
              image: previewImage.value ?? File(''),
            ));
      }
    }
  }

  Future<void> openGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      previewImage.value = File(pickedFile.path);

      if (previewImage.value != null) {
        Get.to(() => PostDrip1(
              thumbnail: previewImage.value!,
              videoFile: videoFile.value ?? XFile(''),
              image: previewImage.value ?? File(''),
            ));
      }
    }
  }

  Future<void> fetchGalleryImages() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      final List<AssetEntity> media = await albums.first.getAssetListPaged(
        page: 0,
        size: 100,
      );
      print("Number of images fetched: ${media.length}");

      images.value = media;
    } else {
      // PhotoManager.openSetting();
    }
  }
}
