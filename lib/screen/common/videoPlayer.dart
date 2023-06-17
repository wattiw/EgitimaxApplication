import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

class CustomVideoPlayerWidget extends StatefulWidget {
  final Uint8List? videoData;

  const CustomVideoPlayerWidget({this.videoData});

  @override
  _CustomVideoPlayerWidgetState createState() =>
      _CustomVideoPlayerWidgetState();
}

class _CustomVideoPlayerWidgetState extends State<CustomVideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.videoData != null) {
      _createTempFile().then((vController) {
        _controller = vController;
        _initializeVideoPlayerFuture = _controller.initialize().then((_) {
          setState(() {
            _controller.play();
            _isPlaying = true;
          });
        });

        _controller.addListener(() {
          setState(() {});
        });

        _controller.setLooping(true);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _rewind() {
    setState(() {
      final Duration position = _controller.value.position;
      final Duration seekTime = const Duration(seconds: 10);
      final Duration newPosition = position - seekTime;
      _controller.seekTo(newPosition);
    });
  }

  void _forward() {
    setState(() {
      final Duration position = _controller.value.position;
      final Duration seekTime = const Duration(seconds: 10);
      final Duration newPosition = position + seekTime;
      _controller.seekTo(newPosition);
    });
  }

  void _toggleVolume() {
    setState(() {
      _volume = _volume > 0 ? 0 : 1;
      _controller.setVolume(_volume);
    });
  }

  bool _isFullScreen = false;

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  Future<VideoPlayerController> _createTempFile() async {
    if (kIsWeb) {
      final dataUrl =
          'data:video/mp4;base64,${base64Encode(widget.videoData!)}';
      return VideoPlayerController.network(dataUrl);
    } else {
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/temp_video.mp4';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(widget.videoData!);
      return VideoPlayerController.file(tempFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isToolbarVisible = true;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isToolbarVisible = !isToolbarVisible;
            });
          },
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        AnimatedOpacity(
          opacity: isToolbarVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.black54,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                  LinearProgressIndicator(
                    value: _controller.value.position.inSeconds.toDouble() /
                        _controller.value.duration.inSeconds.toDouble(),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.grey,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.replay_10,
                        color: Colors.white,
                      ),
                      onPressed: _rewind,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.forward_10,
                        color: Colors.white,
                      ),
                      onPressed: _forward,
                    ),
                    IconButton(
                      icon: Icon(
                        _volume > 0 ? Icons.volume_up : Icons.volume_off,
                        color: Colors.white,
                      ),
                      onPressed: _toggleVolume,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFullScreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
