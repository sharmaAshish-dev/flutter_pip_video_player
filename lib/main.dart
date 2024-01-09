import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIP Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const PIPExampleApp(),
    );
  }
}

class PIPExampleApp extends StatefulWidget {
  const PIPExampleApp({super.key});

  @override
  State<PIPExampleApp> createState() => _PIPExampleAppState();
}

class _PIPExampleAppState extends State<PIPExampleApp> with WidgetsBindingObserver {
  final String videoUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4';
  late Floating pip;
  bool isPipAvailable = false;

  @override
  void initState() {
    pip = Floating();
    super.initState();
    _checkPiPAvailability();
  }

  _checkPiPAvailability() async {
    isPipAvailable = await pip.isPipAvailable;
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden && isPipAvailable) {
      pip.enable(aspectRatio: const Rational.landscape());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PiPSwitcher(
      childWhenDisabled: Scaffold(
        body: Column(
          children: [
            VideoPlayerWidget(videoUrl: videoUrl),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (isPipAvailable) {
                    pip.enable(aspectRatio: const Rational.landscape());
                  }
                },
                child: Text(isPipAvailable ? 'Enable PIP' : 'PIP not available'),
              ),
            ),
          ],
        ),
      ),
      childWhenEnabled: VideoPlayerWidget(videoUrl: videoUrl),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(
                key: UniqueKey(),
                _controller,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
