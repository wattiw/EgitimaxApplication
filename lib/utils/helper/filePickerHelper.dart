import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class FilePickerHelper {
  static Future<FilePickerHelperResult?> pickFile() async {
    if (kIsWeb) {
      return _pickFileWeb();
    } else {
      return _pickFileMobile();
    }
  }

  static Future<FilePickerHelperResult?> _pickFileMobile() async {
    final FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.video, allowMultiple: false);

    if (result != null && result.files.isNotEmpty) {
      final File file = File(result.files.first.path!);
      var data = await file.readAsBytes();

      return FilePickerHelperResult(
          data, result.files.first.name, result.files.first.extension);
    }

    return null;
  }

  static Future<FilePickerHelperResult?> _pickFileWeb() async {
    // get file
    final result = await FilePicker.platform
        .pickFiles(type: FileType.video, allowMultiple: false);

    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      var data = fileBytes;
      return FilePickerHelperResult(
          data, result.files.first.name, result.files.first.extension);
    }

    return null;
  }
}

class FilePickerHelperResult {
  Uint8List? data;
  String fileName;
  String? fileExtension;
  int duration=0;

  FilePickerHelperResult(this.data, this.fileName, this.fileExtension);

 Future<int> getDuration() async {
    // Return the video duration based on the data if available
    if (data != null) {
      // Perform the necessary calculations here
      duration= await VideoDuration.calculate(fileExtension, videoData: data);
      return duration;
    }
    duration= 0; // Return null if data is not available
    return duration;
  }
}

class VideoDuration {
  static bool isVideoContent(String? videoFormat) {
    videoFormat = '.${videoFormat ?? ''}';
    if (videoFormat == null) {
      return false;
    }
    switch (videoFormat.toLowerCase()) {
      case ".mp4":
        return true;
      case ".avi":
        return true;
      case ".mov":
        return true;
      case ".wmv":
        return true;
      case ".flv":
        return true;
      case ".mkv":
        return true;
      case ".webm":
        return true;
      case ".3gp":
        return true;
      case ".ogg":
        return true;
      // Add more video format cases if needed
      default:
        return false;
    }
  }

  static Future<int> calculate(
    String? fileExtension, {
    Uint8List? videoData,
    String? videoUrl,
    String? assetPath,
  }) async {
    if (!isVideoContent(fileExtension)) {
      return 0;
    }

    if (videoData != null) {
      if (kIsWeb) {
        final dataUrl = 'data:video/mp4;base64,${base64Encode(videoData)}';
        var vc = VideoPlayerController.network(dataUrl);
        await vc.initialize();

        Duration videoDuration = vc.value.duration;
        int minutes = videoDuration.inMinutes;
        int seconds = videoDuration.inSeconds.remainder(60);
        vc.dispose();

        var duration = minutes * 60 + seconds;
        return duration;
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/temp_video.mp4';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(videoData);
        var vc = VideoPlayerController.file(tempFile);
        await vc.initialize();

        Duration videoDuration = vc.value.duration;
        int minutes = videoDuration.inMinutes;
        int seconds = videoDuration.inSeconds.remainder(60);
        vc.dispose();
        var duration = minutes * 60 + seconds;
        return duration;
      }
    } else if (videoUrl != null) {
      var vc = VideoPlayerController.network(videoUrl);
      await vc.initialize();

      Duration videoDuration = vc.value.duration;
      int minutes = videoDuration.inMinutes;
      int seconds = videoDuration.inSeconds.remainder(60);
      vc.dispose();

      var duration = minutes * 60 + seconds;
      return duration;
    } else if (assetPath != null) {
      var vc = VideoPlayerController.asset(assetPath);
      await vc.initialize();

      Duration videoDuration = vc.value.duration;
      int minutes = videoDuration.inMinutes;
      int seconds = videoDuration.inSeconds.remainder(60);
      vc.dispose();
      var duration = minutes * 60 + seconds;
      return duration;
    } else {
      return 0;
    }
  }
}
