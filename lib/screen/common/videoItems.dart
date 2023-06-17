import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerObject extends StatefulWidget {
  final bool looping;
  final bool autoplay;
  final VideoPlayerController? videoPlayerController;
  final Function(bool)? isFullScreen;

  VideoPlayerObject({
    required this.looping,
    required this.autoplay,
    required this.videoPlayerController,
    required this.isFullScreen
  });

  @override
  _VideoPlayerObjectState createState() => _VideoPlayerObjectState();
}

class _VideoPlayerObjectState extends State<VideoPlayerObject> {
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initChewieController();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    super.dispose();
  }

  void initChewieController() {
    if (widget.videoPlayerController != null) {
      _chewieController = ChewieController(
        videoPlayerController: widget.videoPlayerController!,
        aspectRatio: widget.videoPlayerController!.value.aspectRatio,
        autoInitialize: true,
        autoPlay: widget.autoplay,
        looping: widget.looping,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          );
        },
        placeholder: Container(
          color: Colors.transparent,
        ),
        systemOverlaysOnEnterFullScreen: [SystemUiOverlay.top, SystemUiOverlay.bottom],
        deviceOrientationsOnEnterFullScreen: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      );
      _chewieController!.addListener(_onVideoPlayerValueChanged);
    }
  }

  void _onVideoPlayerValueChanged() {

    if (_chewieController!.isFullScreen) {
      // Handle full-screen mode
    } else {
      // Exiting full-screen mode

      _chewieController=ChewieController(
        videoPlayerController: widget.videoPlayerController!,
        aspectRatio: widget.videoPlayerController!.value.aspectRatio,
        autoInitialize: true,
        autoPlay: widget.autoplay,
        looping: widget.looping,
        fullScreenByDefault: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          );
        },
        placeholder: Container(
          color: Colors.transparent,
        ),
        systemOverlaysOnEnterFullScreen: [SystemUiOverlay.top, SystemUiOverlay.bottom],
        deviceOrientationsOnEnterFullScreen: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      );
      _chewieController!.addListener(_onVideoPlayerValueChanged);

      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Chewie(
            controller: _chewieController!,
          ),
        ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.all(1.0),
        child: CircularProgressIndicator(),
      );
    }
  }
}

class VideoControllerProvider {
  static Future<VideoPlayerController?> createController({
    Uint8List? videoData,
    String? videoUrl,
    String? assetPath,
  }) async {
    if (videoData != null) {
      if (kIsWeb) {
        final dataUrl = 'data:video/mp4;base64,${base64Encode(videoData)}';
        return VideoPlayerController.network(dataUrl);
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/temp_video.mp4';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(videoData);
        return VideoPlayerController.file(tempFile);
      }
    } else if (videoUrl != null) {
      return VideoPlayerController.network(videoUrl);
    } else if (assetPath != null) {
      return VideoPlayerController.asset(assetPath);
    } else {
      return null;
    }
  }
}
