import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  const VideoPlayerScreen({super.key, required this.url});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? controller;

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  Future<void> initVideo() async {
    try {
      print("VIDEO URL: ${widget.url}");

      if (widget.url.isEmpty) {
        throw Exception("Empty URL");
      }

      controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );

      await controller!.initialize();

      controller!.setLooping(true);
      controller!.play(); // 🔥 auto play

      setState(() => loading = false);

    } catch (e) {
      print("VIDEO ERROR: $e");

      setState(() {
        error = "Video failed to load";
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player")),

      body: Center(
        child: loading
            ? const CircularProgressIndicator()

            : error != null
                ? Text(error!, style: const TextStyle(color: Colors.red))

                : controller != null &&
                        controller!.value.isInitialized

                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: controller!.value.aspectRatio,
                            child: VideoPlayer(controller!),
                          ),

                          const SizedBox(height: 20),

                          //  Progress bar
                          Slider(
                            value: controller!.value.position.inSeconds.toDouble(),
                            min: 0,
                            max: controller!.value.duration.inSeconds.toDouble(),
                            onChanged: (value) {
                              controller!.seekTo(Duration(seconds: value.toInt()));
                            },
                          ),

                          //  Duration text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatDuration(controller!.value.position)),
                              Text(formatDuration(controller!.value.duration)),
                            ],
                          ),

                          const SizedBox(height: 10),

                          //  Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10, size: 30),
                                onPressed: () {
                                  final pos = controller!.value.position;
                                  controller!.seekTo(pos - const Duration(seconds: 10));
                                },
                              ),

                              IconButton(
                                icon: Icon(
                                  controller!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 40,
                                ),
                                onPressed: () {
                                  setState(() {
                                    controller!.value.isPlaying
                                        ? controller!.pause()
                                        : controller!.play();
                                  });
                                },
                              ),

                              IconButton(
                                icon: const Icon(Icons.forward_10, size: 30),
                                onPressed: () {
                                  final pos = controller!.value.position;
                                  controller!.seekTo(pos + const Duration(seconds: 10));
                                },
                              ),
                            ],
                          ),
                        ],
                      )

                    : const Text("Video not available"),
      ),
    );
  }
}